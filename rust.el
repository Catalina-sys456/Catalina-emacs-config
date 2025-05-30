;;;rust language

 (use-package rust-mode
 :ensure t
 :functions dap-register-debug-template
 :bind
 ("C-c C-c" . rust-run)
 :hook
 (rust-mode . lsp-deferred)
 :config
 ;; debug
 (require 'dap-gdb-lldb)
 (dap-register-debug-template "Rust::LLDB Run Configuration"
                (list :type "lldb"
     :request "launch"
        :name "rust-lldb::Run"
     :gdbpath "rust-lldb"
     :target nil
     :cwd nil)))

(use-package cargo
 :ensure t
 :hook
 (rust-mode . cargo-minor-mode))
 
