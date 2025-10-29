set shell := ["bash", "-c"]
set dotenv-load := true
set dotenv-filename := 'dotenv-unit'
set dotenv-required := true

export PERL5LIB := \
  justfile_directory() / "lib" + ":" + \
  justfile_directory() / "local" / "lib" / "perl5"

export LOCAL_BIN := justfile_directory() / "local" / "bin"

export PATH := LOCAL_BIN + ":" + env_var("PATH")

PERLCRITIC := "perlcritic" + \
  " --profile " + justfile_directory() / ".perlcritic"

PERLIMPORTS := "perlimports" + \
  " -i --no-preserve-unused" + \
  " --libs lib" + \
  " --ignore-modules-filename " + \
  justfile_directory() / ".perlimports-ignore" + " -f"

PERLTIDY := 'perltidier -i=2 -pt=2 -bt=2 -pvt=2 -b -cs '

YATH := 'yath --max-open-jobs=1000'

default:
    @just --list

# -- App rules.

all:
    just --justfile {{ justfile() }} check critic imports tidy test

# Iniitialize carton.
carton:
    mkdir -p local/bin;
    curl -L https://cpanmin.us/ -o local/bin/cpanm
    @chmod +x local/bin/cpanm
    env -u PERL5LIB cpanm -l local -n -f Carton

# perl -c on all files.
check:
    for i in `find lib -name \*.pm`; do perl -c $i; done
    for i in `find t -name \*.t`; do perl -c $i; done

# perlcritic on all files - see .perlcritic for exceptions.
critic:
    find lib -name \*.pm -print0 | xargs -0 {{ PERLCRITIC }}
    find t -name \*.t -print0 | xargs -0 {{ PERLCRITIC }} --theme=tests

# Install carton dependencies; follows "carton" rule.
deps:
    carton install

# Update all carton dependencies.
update:
    carton update

# perlimports on all files.
imports:
    find lib -name \*.pm -print0 | xargs -0 {{ PERLIMPORTS }} 2>/dev/null
    find t -name \*.t -print0 | xargs -0 {{ PERLIMPORTS }} 2>/dev/null

# Open a perl repl.
repl:
    perl -de 0

# Run a command.
run *CMD:
    {{ CMD }}

# Run all tests.
test BASE:
    pushd {{ BASE }} && find t -name \*.t -print0 | xargs -0 {{ YATH }}

# perltidy on all files.
tidy:
    find . -name \*.pm -print0 | xargs -0 {{ PERLTIDY }} 2>/dev/null
    find . -name \*.t -print0 | xargs -0 {{ PERLTIDY }} 2>/dev/null
    @find -name \*bak -delete
    @find -name \*tdy -delete
    @find -name \*.ERR -delete

# Run a single test; e.g. "just yath experiment0 t/basic.t".
yath BASE TEST:
    pushd {{ BASE }} && {{ YATH }} {{ TEST }}

daemon BASE:
    pushd {{ BASE }} && ./script/{{ BASE }} daemon

