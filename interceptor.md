```
bool InterceptFunction(void *interceptor, void *old_function,
                       void *new_function, void **callback_function,
                       void (*error_callback)(void *, const char *),
                       void *error_callback_baton) {
  Error error =
      static_cast<InterceptorImpl *>(interceptor)
          ->InterceptFunction(old_function, new_function, callback_function);
}
Error InterceptorImpl::InterceptFunction(void *old_function, void *new_function,
                                         void **callback_function) {
  if (!callback_function) {
    // TODO: Verify that the function is long enough for placing a trampoline
    //       inside it. If it isn't then currently we are overwriting the
    //       beginning of the next function as well causing potential SIGILL.

    // We don't have to set up a callback function so installing a trampoline
    // without generating compensation instructions is sufficient.
    TrampolineConfig full_config = target_->GetFullTrampolineConfig();
    return InstallTrampoline(full_config, old_function, new_function);
  }
}
Error InterceptorImpl::InstallTrampoline(const TrampolineConfig &config,
                                         void *old_function,
                                         void *new_function) {
                                         
```