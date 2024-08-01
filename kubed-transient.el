;;; kubed-transient.el --- Kubernetes transient menus   -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Eshel Yaron

;; Author: Eshel Yaron <me@eshelyaron.com>
;; Keywords: tools

;;; Commentary:

;; This library extends Kubed with transient menus for various
;; Kubernetes operations.

;;; Code:

(require 'kubed)
(require 'transient)

(defclass kubed-transient-infix (transient-infix) ())

(defun kubed-transient-read-namespace (prompt _initial-input _history)
  "Prompt with PROMPT for Kubernetes namespace."
  (kubed-read-namespace prompt (kubed-current-namespace)))

(defun kubed-transient-read-ingressclass (prompt _initial-input _history)
  "Prompt with PROMPT for Kubernetes ingress class."
  (kubed-read-ingressclass prompt))

(defun kubed-transient-read-service-and-port (prompt _initial-input _history)
  "Prompt with PROMPT for Kubernetes service and port number."
  (let ((service (kubed-read-service prompt)))
    (concat service ":" (number-to-string (read-number "Port number: ")))))

(defun kubed-transient-read-resource-definition-file-name
    (_prompt _initial-input _history)
  "Read and return Kubernetes resource definition file name."
  (kubed-read-resource-definition-file-name))

;;;###autoload
(transient-define-prefix kubed-transient ()
  "Perform Kubernetes operation."
  ["Kubernetes"
   ;; First column.
   [("+" "Create"  kubed-transient-create)
    ("*" "Apply"   kubed-transient-apply)
    ("r" "Run"     kubed-transient-run)
    ("a" "Attach"  kubed-transient-attach)
    ("d" "Diff"    kubed-transient-diff)]
   ;; Second column.
   [("X" "Exec"    kubed-transient-exec)
    ("P" "Patch"   kubed-transient-patch)
    ("R" "Rollout" kubed-transient-rollout)
    ("E" "Explain" kubed-explain)
    ("!" "Command line" kubed-kubectl-command)]])

;;;###autoload
(transient-define-prefix kubed-transient-rollout ()
  "Manage Kubernetes deployments."
  ["Kubernetes Rollout\n"
   ["Actions"
    ("W" "Watch"   kubed-watch-deployment-status)
    ("R" "Restart" kubed-restart-deployment)
    ("!" "Command line" kubed-kubectl-command)]
   ["Options"
    ("-n" "Namespace" "--namespace="
     :prompt "Namespace" :reader kubed-transient-read-namespace)]]
  (interactive)
  (transient-setup 'kubed-transient-rollout nil nil
                   :scope '("rollout")))

;;;###autoload
(transient-define-prefix kubed-transient-attach ()
  "Attach to running process in container in Kubernetes pod."
  ["Kubernetes Attach\n"
   ["Actions"
    ("a" "Attach" kubed-attach)
    ("!" "Command line" kubed-kubectl-command)]
   ["Switches"
    ("-i" "Open stdin" "--stdin")
    ("-t" "Allocate TTY" "--tty")]
   ["Options"
    ("-n" "Namespace" "--namespace="
     :prompt "Namespace" :reader kubed-transient-read-namespace)]]
  (interactive)
  (transient-setup 'kubed-transient-attach nil nil
                   :value '("--stdin" "--tty")
                   :scope '("attach")))

;;;###autoload
(transient-define-prefix kubed-transient-diff ()
  "Display difference between Kubernetes resource definition and current state."
  ["Kubernetes Diff\n"
   ["Actions"
    ("d" "Diff" kubed-diff)
    ("!" "Command line" kubed-kubectl-command)]
   ["Switches"
    ("-M" "Include managed fields" "--show-managed-fields")]
   ["Options"
    ("-f" "Definition file" "--filename="
     :reader kubed-transient-read-resource-definition-file-name)]]
  (interactive)
  (transient-setup 'kubed-transient-diff nil nil
                   :scope '("diff")))

;;;###autoload
(transient-define-prefix kubed-transient-exec ()
  "Execute command in Kubernetes pod."
  ["Kubernetes Exec\n"
   ["Actions"
    ("X" "Execute" kubed-exec)
    ("!" "Command line" kubed-kubectl-command)]
   ["Switches"
    ("-i" "Open stdin" "--stdin")
    ("-t" "Allocate TTY" "--tty")]
   ["Options"
    ("-n" "Namespace" "--namespace="
     :prompt "Namespace" :reader kubed-transient-read-namespace)
    ("--" "Command" "-- ="
     :prompt "Command: ")]]
  (interactive)
  (transient-setup 'kubed-transient-exec nil nil
                   :value '("--stdin" "--tty")
                   :scope '("exec")))

;;;###autoload
(transient-define-prefix kubed-transient-run ()
  "Run container image in a Kubernetes pod."
  ["Kubernetes Run\n"
   ["Actions"
    ("r" "Run" kubed-run)
    ("!" "Command line" kubed-kubectl-command)]
   ["Switches"
    ("-A" "Attach" "--attach")
    ("-i" "Open stdin" "--stdin")
    ("-t" "Allocate TTY" "--tty")
    ("-R" "Remove after exit" "--rm")
    ("-C" "Override container command" "--command")]
   ["Options"
    ("-n" "Namespace" "--namespace="
     :prompt "Namespace" :reader kubed-transient-read-namespace)
    ("-I" "Image" "--image="
     :prompt "Image to deploy: ")
    ("-p" "Port" "--port="
     :prompt "Port to expose: " :reader transient-read-number-N+)
    ("-E" "Env vars" "--env="
     :prompt "Set environment VAR=VAL: "
     :multi-value repeat)
    ("--" "Arguments" "-- ="
     :prompt "Arguments for container command: ")]]
  (interactive)
  (transient-setup 'kubed-transient-run nil nil
                   :scope '("run")))

;;;###autoload
(transient-define-prefix kubed-transient-apply ()
  "Apply configuration to Kubernetes resource."
  ["Kubernetes Apply\n"
   ["Actions"
    ("*" "Apply" kubed-apply)
    ("!" "Command line" kubed-kubectl-command)]
   ["Options"
    ("-f" "Definition file" "--filename="
     :reader kubed-transient-read-resource-definition-file-name)]]
  (interactive)
  (transient-setup 'kubed-transient-apply nil nil
                   :scope '("apply")))

;;;###autoload
(transient-define-prefix kubed-transient-patch ()
  "Apply patch to Kubernetes resource."
  ["Kubernetes Patch\n"
   ["Actions"
    ("P" "Patch" kubed-patch)
    ("!" "Command line" kubed-kubectl-command)]
   ["Options"
    ("-n" "Namespace" "--namespace="
     :prompt "Namespace" :reader kubed-transient-read-namespace)
    ("-t" "Patch type" "--type="
     :prompt "Patch type: "
     :choices ("strategic" "merge" "json"))]]
  (interactive)
  (transient-setup 'kubed-transient-patch nil nil
                   :scope '("patch")))

;;;###autoload
(transient-define-prefix kubed-transient-create ()
  "Create Kubernetes resource."
  ["Kubernetes Create\n"
   ["Actions"
    ("+" "Create" kubed-create)
    ("!" "Command line" kubed-kubectl-command)]
   ["Options"
    ("-f" "Definition file" "--filename="
     :reader kubed-transient-read-resource-definition-file-name)]
   ["Kinds"
    ("d" "deployment" kubed-transient-create-deployment)
    ("n" "namespace" kubed-create-namespace)
    ("c" "cronjob" kubed-transient-create-cronjob)
    ("j" "job" kubed-transient-create-job)
    ("i" "ingress" kubed-transient-create-ingress)]]
  (interactive)
  (transient-setup 'kubed-transient-create nil nil
                   :scope '("create")))

;;;###autoload
(transient-define-prefix kubed-transient-create-cronjob ()
  "Create Kubernetes cronjob."
  ["Kubernetes Create CronJob\n"
   ["Actions"
    ("+" "Create" kubed-create-cronjob)
    ("!" "Command line" kubed-kubectl-command)]
   ["Options"
    ("-n" "Namespace" "--namespace="
     :prompt "Namespace" :reader kubed-transient-read-namespace)
    ("-I" "Image" "--image="
     :prompt "Image to run: ")
    ("-S" "Schedule" "--schedule="
     :prompt "Cron schedule: ")
    ("--" "Command" "-- ="
     :prompt "Command: ")]]
  (interactive)
  (transient-setup 'kubed-transient-create-cronjob nil nil
                   :scope '("create" "cronjob")))

;;;###autoload
(transient-define-prefix kubed-transient-create-ingress ()
  "Create Kubernetes ingress."
  ["Kubernetes Create Ingress\n"
   ["Actions"
    ("+" "Create" kubed-create-ingress)
    ("!" "Command line" kubed-kubectl-command)]
   ["Options"
    ("-n" "Namespace" "--namespace="
     :prompt "Namespace" :reader kubed-transient-read-namespace)
    ("-c" "Class" "--class="
     :prompt "Class" :reader kubed-transient-read-ingressclass)
    ("-d" "Default backend service" "--default-backend="
     :prompt "Default backend service"
     :reader kubed-transient-read-service-and-port)
    ("-a" "Annotation" "--annotation="
     :prompt "Ingress annotations: "
     :multi-value repeat)
    ("-r" "Rule" "--rule="
     :prompt "Ingress rule: ")]]
  (interactive)
  (transient-setup 'kubed-transient-create-ingress nil nil
                   :scope '("create" "ingress")))

;;;###autoload
(transient-define-prefix kubed-transient-create-deployment ()
  "Create Kubernetes deployment."
  ["Kubernetes Create Deployment\n"
   ["Actions"
    ("+" "Create" kubed-create-deployment)
    ("!" "Command line" kubed-kubectl-command)]
   ["Options"
    ("-n" "Namespace" "--namespace="
     :prompt "Namespace" :reader kubed-transient-read-namespace)
    ("-r" "Replicas" "--replicas="
     :prompt "Number of replicas: " :reader transient-read-number-N+)
    ("-I" "Image" "--image="
     :prompt "Images to deploy: "
     :multi-value repeat)
    ("-p" "Port" "--port="
     :prompt "Port to expose: " :reader transient-read-number-N+)
    ("--" "Command" "-- ="
     :prompt "Command: ")]]
  (interactive)
  (transient-setup 'kubed-transient-create-deployment nil nil
                   :scope '("create" "deployment")))

;;;###autoload
(transient-define-prefix kubed-transient-create-job ()
  "Create Kubernetes job."
  ["Kubernetes Create Job\n"
   ["Actions"
    ("+" "Create" kubed-create-job)
    ("c" "Create from cronjob" kubed-create-job-from-cronjob)
    ("!" "Command line" kubed-kubectl-command)]
   ["Options"
    ("-n" "Namespace" "--namespace="
     :prompt "Namespace" :reader kubed-transient-read-namespace)
    ("-I" "Image" "--image="
     :prompt "Image to run: ")
    ("--" "Command" "-- ="
     :prompt "Command: ")]]
  (interactive)
  (transient-setup 'kubed-transient-create-job nil nil
                   :scope '("create" "job")))

(provide 'kubed-transient)
;;; kubed-transient.el ends here
