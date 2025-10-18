set shell := ["bash", "-c"]
set dotenv-load := true
set dotenv-filename := 'dotenv-unit'
set dotenv-required := true

with_perl5lib := 'export PERL5LIB=${PWD}/lib:${PWD}/local/lib/perl5'
perlcritic := 'local/bin/perlcritic --profile ${PWD}/.perlcritic'
perlimports := 'local/bin/perlimports -i --no-preserve-unused --libs lib --ignore-modules-filename ${PWD}/.perlimports-ignore -f '
perltidy := 'local/bin/perltidier -i=2 -pt=2 -bt=2 -pvt=2 -b -cs '
yath := 'local/bin/yath --max-open-jobs=1000'

default:
    @just --list

# -- App rules.

all:
    just --justfile {{ justfile() }} check critic imports tidy test

# Iniitialize carton.
carton:
    mkdir -p local;
    env -u PERL5LIB cpanm -l local -n -f Carton

# perl -c on all files.
check:
    @{{ with_perl5lib }}; \
    for i in `find lib -name \*.pm`; do perl -c $i; done
    @{{ with_perl5lib }}; \
    for i in `find t -name \*.t`; do perl -c $i; done

# perlcritic on all files - see .perlcritic for exceptions.
critic:
    @{{ with_perl5lib }}; \
    find lib -name \*.pm -print0 | xargs -0 {{ perlcritic }}
    @{{ with_perl5lib }}; \
    find t -name \*.t -print0 | xargs -0 {{ perlcritic }} --theme=tests

# DBD::Pg requires OPTIMIZE tweaks up until v3.18.
dbd-pg:
    @{{ with_perl5lib }}; \
    cpanm -l local --configure-args "OPTIMIZE='-std=gnu17'" DBD::Pg

# Install carton dependencies; follows "carton" rule.
deps: dbd-pg
    @{{ with_perl5lib }}; \
    local/bin/carton install

# Update all carton dependencies.
update: dbd-pg
    @{{ with_perl5lib }}; \
    local/bin/carton update

# perlimports on all files.
imports:
    @{{ with_perl5lib }}; \
    find lib -name \*.pm -print0 | xargs -0 {{ perlimports }} 2>/dev/null
    @{{ with_perl5lib }}; \
    find t -name \*.t -print0 | xargs -0 {{ perlimports }} 2>/dev/null

# Open a perl repl with lib path set for this project's files.
repl:
    @{{ with_perl5lib }}; \
    perl -de 0

# Run all tests.
test:
    @{{ with_perl5lib }}; \
    find t -name \*.t -print0 | xargs -0 {{ yath }}

# perltidy on all files.
tidy:
    @{{ with_perl5lib }}; \
    find . -name \*.pm -print0 | xargs -0 {{ perltidy }} 2>/dev/null
    @{{ with_perl5lib }}; \
    find . -name \*.t -print0 | xargs -0 {{ perltidy }} 2>/dev/null
    @find -name \*bak -delete
    @find -name \*tdy -delete
    @find -name \*.ERR -delete

# Run a single test; e.g. "just yath t/00-test.t".
yath TEST:
    @{{ with_perl5lib }}; \
    {{ yath }} {{ TEST }}
