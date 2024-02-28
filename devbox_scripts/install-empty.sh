# Copyright (C) 2023 University of Münster.
#
# Invenio-devbox is free software; you can redistribute it and/or
# modify it under the terms of the MIT License; see LICENSE file for more
# details.


function echo_info() {
    tput setaf 2
    echo -e "$1"
    tput sgr0
}
function echo_failure() {
    tput setaf 1
    echo -e "$1"
    tput sgr0
    exit 1
}
function echo_warning() {
    tput setaf 3
    echo -e "$1"
    tput sgr0
}
function save_var_to_env() {
    # Function to save variable to .envrc
    local varname="$1"
    local value="$(eval echo \$$varname)"
    if grep -q "^export $varname=" .envrc; then
        # If the variable already exists in the file, overwrite it
        sed -i "/^export $varname=/c\export $varname=\"$value\"" .envrc
    else
        # If the variable doesn't exist in the file, append it
        echo "export $varname=\"$value\"" >>.envrc
    fi
}
function write_config_file() {

    local INSTANCE_NAME="$1"
    #create a .invenio file to customize the init process without user-input
    echo_info "Creating .invenio file"
    INSTANCE_NAMEDASH=$(echo "$INSTANCE_NAME" | sed -e 's/ /-/g' | tr '[:upper:]' '[:lower:]')
    INSTANCE_NAMEUNDERSCORE=$(echo "$INSTANCE_NAME" | sed -e 's/ /_/g' | tr '[:upper:]' '[:lower:]')
    echo -e "[cli]\nflavour = RDM\nlogfile = /logs/invenio-cli.log\n\n[cookiecutter]\nproject_name = ${INSTANCE_NAME}\nproject_shortname = ${INSTANCE_NAMEDASH}\npackage_name = ${INSTANCE_NAMEUNDERSCORE}\nproject_site = ${INSTANCE_NAMEDASH}.com\n#github_repo = ${INSTANCE_NAMEDASH}/${INSTANCE_NAMEDASH}\ndescription = ${INSTANCE_NAME} InvenioRDM Instance\nauthor_name = CERN\nauthor_email = info@$INSTANCE_NAMEDASH.com\nyear = 2023\ndatabase = postgresql\nsearch = opensearch2\nfile_storage = local\ndevelopment_tools = yes\nsite_code = yes\n_template = https://github.com/inveniosoftware/cookiecutter-invenio-rdm.git" >".invenio"

}
function install_instance() {
    local FOLDER=$(pwd)
    echo "Please enter the name of the instance (default: my-site):"
    read DEVBOX_INSTANCE_PATH
    if [ -z "$DEVBOX_INSTANCE_PATH" ]; then
        DEVBOX_INSTANCE_PATH="my-site"
        invenio-cli init --no-input -c master
    else
        write_config_file $DEVBOX_INSTANCE_PATH
        invenio-cli init --no-input -c master --config ".invenio"
    fi
    save_var_to_env DEVBOX_INSTANCE_PATH
    cd "$DEVBOX_INSTANCE_PATH"

    echo_info "Installing InvenioRDM instance in $DEVBOX_INSTANCE_PATH"

    echo "Running invenio-cli install..."

    invenio_init_status=$?
    # install instance
    invenio-cli install
    invenio_install_status=$?
    echo "RDM_RECORDS_USER_FIXTURE_PASSWORDS = { 'admin@inveniosoftware.org': '123456' }" >>invenio.cfg
    echo_info "Setting up services without demo data"
    invenio-cli services setup -f --no-demo-data

    invenio_services_status=$?

    # activate admin user
    pipenv run invenio users activate admin@inveniosoftware.org
    sed -i 's/SECURITY_LOGIN_WITHOUT_CONFIRMATION = False/SECURITY_LOGIN_WITHOUT_CONFIRMATION = True/' invenio.cfg
    # check if all steps were successful
    if [ "$invenio_init_status" -eq 0 ] && [ "$invenio_install_status" -eq 0 ] && [ "$invenio_services_status" -eq 0 ]; then
        echo "InvenioRDM is installed."
    fi
    source "$DEVBOX_PROJECT_ROOT/.envrc"
}

install_instance
