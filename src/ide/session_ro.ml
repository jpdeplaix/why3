(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-2011                                               *)
(*    François Bobot                                                      *)
(*    Jean-Christophe Filliâtre                                           *)
(*    Claude Marché                                                       *)
(*    Andrei Paskevich                                                    *)
(*                                                                        *)
(*  This software is free software; you can redistribute it and/or        *)
(*  modify it under the terms of the GNU Library General Public           *)
(*  License version 2.1, with the special exception on linking            *)
(*  described in file LICENSE.                                            *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  *)
(*                                                                        *)
(**************************************************************************)

(** This module is a wrapper around Session which is simpler when you
    only want to read a session *)

open Why3
open Util



type session =
    { files : file list;
      provers : prover_data Mstr.t}

and file =
    { file_name : string;
      theories  : theory list;
      file_verified : bool}

and theory =
    { theory_name : string;
      theory : Theory.theory;
      goals : goal list;
      theory_verified : bool}

and goal =
    { goal_name : string;
      goal_expl : string;
      goal_verified : bool;
      transformations : transf Mstr.t;
      external_proofs : proof_attempt Mstr.t}

and transf =
    { transf_name : string;
      transf_verified : bool;
      subgoals : goal list}

and prover_data =
    { prover_name : string;
      prover_version : string;
      (** will be added again when session records it *)
      (* prover_interactive : bool; *)
    }

and proof_attempt_status =
  | Undone
  | Done of Call_provers.prover_result (** external proof done *)
  | InternalFailure of exn (** external proof aborted by internal error *)

and proof_attempt =
  { prover : prover_data;
    proof_state : proof_attempt_status;
    timelimit : int;
    proof_obsolete : bool;
    edited_as : string option;
  }
    (** a proof attempt for a given goal *)

type env =
    { env : Env.env;
      config : Whyconf.config}

let read_config ?(includes=[]) conf_path_opt =
  let config = Whyconf.read_config conf_path_opt in
  let loadpath = (Whyconf.loadpath (Whyconf.get_main config)) @ includes in
  let env = Env.create_env loadpath in
  {env = env; config = config}


let get_provers env =
  let provers = Whyconf.get_provers env.config in
  let get_prover_data pr =
      { prover_name = pr.Whyconf.name;
        prover_version = pr.Whyconf.version;
        (* prover_interactive = pr.Whyconf.interactive; *)
      }
  in
  Mstr.map get_prover_data provers

module Observer_dumb : Session.OBSERVER =
struct
  type key = unit
  let create ?parent:_ () = ()
  let remove _ = ()
  let reset () = ()
  let idle _ = ()
  let timeout ~ms:_ _ = ()
  let notify_timer_state _ _ _ = ()
end


module Read_project (O : Session.OBSERVER)
  (P : sig val project_dir : string end) =
struct
  module M = Session.Make(Observer_dumb)

  let old_provers = ref Mstr.empty

  let get_prover_by_id pid =
    try Mstr.find pid !old_provers
    with Not_found -> assert false (** the provers must be an old_provers *)

  let read_prover_option po =
    get_prover_by_id (match po with
      | M.Detected_prover pd -> pd.Session.prover_id
      | M.Undetected_prover s -> s)

  let read_attempt_status = function
    | Session.Undone | Session.Scheduled | Session.Interrupted
    | Session.Running | Session.Unedited -> Undone
    | Session.Done pr -> Done pr
    | Session.InternalFailure exn -> InternalFailure exn

  let read_edited_as prover ea =
    match prover, ea with
      | (_, "") | (M.Detected_prover {Session.interactive = false},_) -> None
      | _ -> Some (Filename.concat P.project_dir ea)

  let rec read_trans key transf acc =
    Mstr.add key
      { transf_name = Session.transformation_id transf.M.transf;
        transf_verified = transf.M.transf_proved;
        subgoals = List.map read_goal transf.M.subgoals;
      } acc

  and read_proof key pa acc =
    Mstr.add key
      { prover = read_prover_option pa.M.prover;
        proof_state = read_attempt_status pa.M.proof_state;
        timelimit = pa.M.timelimit;
        proof_obsolete = pa.M.proof_obsolete;
        edited_as = read_edited_as pa.M.prover pa.M.edited_as;
      } acc

  and read_goal g =
    let transformations = M.transformations g in
    let transformations = Hashtbl.fold read_trans transformations Mstr.empty in
    let external_proofs = M.external_proofs g in
    let external_proofs = Hashtbl.fold read_proof external_proofs Mstr.empty in

    { goal_name = M.goal_name g;
      goal_expl = M.goal_expl g;
      goal_verified = M.goal_proved g;
      transformations = transformations;
      external_proofs = external_proofs}

  let read_theory th =
    { theory_name = M.theory_name th;
      theory = M.get_theory th;
      goals  = List.map read_goal (M.goals th);
      theory_verified = M.verified th}

  let read_file file =
    { file_name = file.M.file_name;
      theories = List.map read_theory file.M.theories;
      file_verified = file.M.file_verified}

  let read_project_dir ~allow_obsolete ~env =
    let init _ _ = () in
    let notify _ = () in
    let _found_obs = M.open_session ~allow_obsolete
        ~env:env.env ~config:env.config ~init ~notify P.project_dir
    in
    let prover_data (name,version) =
      { prover_name = name; prover_version = version} in
    let op = Mstr.map prover_data (M.get_old_provers ()) in
    old_provers := op;
    {files = List.map read_file (M.get_all_files ());
     provers = op}

end

let read_project_dir ~allow_obsolete ~env project_dir =
  let module Rp = Read_project(Observer_dumb)
        (struct let project_dir = project_dir end)in
  Rp.read_project_dir ~allow_obsolete ~env


open Format
let get_project_dir fname =
  if Sys.file_exists fname then begin
    if Sys.is_directory fname then begin
      eprintf "Info: found directory '%s' for the project@." fname;
      fname
    end
    else begin
      eprintf "Info: found regular file '%s'@." fname;
      let d =
        try Filename.chop_extension fname
        with Invalid_argument _ -> fname
      in
      eprintf "Info: using '%s' as directory for the project@." d;
      d
    end
  end
  else
    raise Not_found