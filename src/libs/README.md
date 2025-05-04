# "Library" scripts
Scripts that contain functions and useful environment variables that are meant to be "sourced" by other scripts.

## yesno.sh
Check if the provided string value is falsy or truthy.
Useful for boolean switches.

### Functions
#### is_no(text)
Returns 0 (true) if value is one of: n, no, f, false, 0, off, null, "" (empty string)
Returns 1 (false) if value is none of the above.
```bash
ENABLE_FEATURE="n"
if is_no "$ENABLE_FEATURE"; then
  echo "Disabling feature"
fi
```

#### is_yes(text)
Exactly inverse of is_no function, returns 0 (true) unless one of the falsy values is provided.
```bash
ENABLE_FEATURE="y"
if is_yes "$ENABLE_FEATURE"; then
  echo "Enabling feature"
fi
```

## tstyle.sh
Terminal styling library, loosely inspired by Symfony Style.
It have many functions that allow you to structure the output in a way that is hopefully easier to read, especially when building any kind of utility scripts.

### Functions
#### tstyle_title(text)
```bash
$ tstyle_title "Building base image"
========================================
          Building base image
========================================
```

#### tstyle_section(text)
```bash
$ tstyle_section "Installing base packages"
------- Installing base packages -------
```

#### tstyle_subsection(text)
```bash
$ tstyle_subsection "Installed packages:"
  Installed packages:
```

#### tstyle_step(text)
```bash
$ tstyle_step "Running APT update"
   -> Running APT update
```

#### tstyle_pstep(index, max, text)
```bash
$ tstyle_pstep 1 2 "Running APT update"
  ( 1/2 ) -> Running APT update
```

#### tstyle_substep()
```bash
$ tstyle_substep "Answering unexpected question"
   * Answering unexpected question
```

#### tstyle_info(text)
```bash
$ tstyle_info "Something not important"
  [INFO] Something not important
```

#### tstyle_ok(text)
```bash
$ tstyle_ok "Something went well"
  [OK] Something went well
```

#### tstyle_success(text)
```bash
$ tstyle_success "Something was a success"
  [SUCCESS] was a success
```

#### tstyle_warn(text)
```bash
$ tstyle_warn "Something might be wrong"
  [WARN] might be wrong
```

#### tstyle_error(text)
```bash
$ tstyle_error "Something IS wrong"
  [ERROR] Something IS wrong
```

#### tstyle_ul(array)
```bash
PACKAGES=(git nginx php)
tstyle_ul ${PACKAGES[@]}
   * git
   * nginx
   * php
```

#### tstyle_ol(array)
```bash
PACKAGES=(git nginx php)
tstyle_ol ${PACKAGES[@]}
   1. git
   2. nginx
   3. php
```

#### tstyle_code(formatted_text)
I am probably going to make this work without having to specify each token at some point.
```bash
PACKAGES=(git nginx php)
tstyle_code "`_tsctc apt-get` `_tscst install` `_tscos -y` `_tscst git` `_tscst nginx` `_tscst php`"
  $ apt-get install -y git nginx php # With colours
```

#### tstyle_enter_level()
Force one additional level of indentation.
Works with most functions, but tstyle_title and tstyle_section reset it back to initial indent.
```bash
tstyle_step "Creating users"
tstyle_enter_level
tstyle_step "Creating "admin" user"
tstyle_step "Creating "guest" user"
   -> Creating users
     -> Creating admin user
     -> Creating guest user
```

#### tstyle_exit_level()
Exit one indent level
```bash
tstyle_step "Creating users"
tstyle_enter_level
tstyle_step "Creating "admin" user"
tstyle_step "Creating "guest" user"
tstyle_exit_level
tstyle_step "Cleaning up"
   -> Creating users
     -> Creating admin user
     -> Creating guest user
   -> Cleaning up
```

#### tstyle_newline()
Output \n character
```bash
tstyle_newline

```
