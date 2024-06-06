#!/bin/bash -eu

function print_help () {
    echo "This script allows to search over movies database"
    echo -e "-d DIRECTORY\n\tDirectory with files describing movies"
    echo -e "-a ACTOR\n\tSearch movies that this ACTOR played in"
    echo -e "-t QUERY\n\tSearch movies with given QUERY in title"
    echo -e "-y YEAR\n\tSearch movies newer than YEAR"
    echo -e "-R REGEX\n\tSearch movies that match REGEX in the plot section"
    echo -e "-i \n\tAdd before -R to make the search case insensitive"
    echo -e "-f FILENAME\n\tSaves results to file (default: results.txt)"
    echo -e "-x\n\tPrints results in XML format"
    echo -e "-h\n\tPrints this help message"
}

function print_error () {
    echo -e "\e[31m\033[1m${*}\033[0m" >&2
}

function get_movies_list () {
    local -r MOVIES_DIR=${1}
    local -r MOVIES_LIST=$(cd "${MOVIES_DIR}" && realpath ./*)
    echo "${MOVIES_LIST}"
}

function query_title () {
    # Returns list of movies from ${1} with ${2} in title slot
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if grep "| Title" "${MOVIE_FILE}" | grep -q "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function query_actor () {
    # Returns list of movies from ${1} with ${2} in actor slot
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if grep "| Actors" "${MOVIE_FILE}" | grep -q "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function query_year () {
    # Returns list of movies from ${1} with > ${2} in year slot
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        YEAR=$(grep "| Year" "${MOVIE_FILE}"| grep -oE '[0-9]{4}')
        if [[ "${YEAR}" -gt "${QUERY}" ]]; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function query_regex () {
    # Returns list of movies from ${1} with ${2} regular expression in the plot section
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if grep "| Plot" "${MOVIE_FILE}" | grep -qoE "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function query_regex_nocase () {
    # Returns list of movies from ${1} with ${2} regular expression in the plot section
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if grep "| Plot" "${MOVIE_FILE}" | grep -qoE -i "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function print_movies () {
    local -r MOVIES_LIST=${1}
    local -r OUTPUT_FORMAT=${2}

    for MOVIE_FILE in ${MOVIES_LIST}; do
        if [[ "${OUTPUT_FORMAT}" == "xml" ]]; then
            print_xml_format "${MOVIE_FILE}"
        else
            cat "${MOVIE_FILE}"
        fi
    done
}

function print_xml_format () {
    local -r FILENAME=${1}

    local TEMP
    TEMP=$(cat "${FILENAME}")

    # TODO: replace first line of equals signs

    # TODO: change 'Author:' into <Author>
    # TODO: change others too

    # append tag after each line
    TEMP=$(echo "${TEMP}" | sed -r 's/([A-Za-z]+).*/\0<\/\1>/')

    # replace the last line with </movie>
    TEMP=$(echo "${TEMP}" | sed '$s/===*/<\/movie>/')

    echo "${TEMP}"
}

while getopts ":hd:t:a:f:xy:R:i" OPT; do
    case ${OPT} in
        h)
            print_help
            exit 0
            ;;
        d)
            PROVIDED_DIR=true
            MOVIES_DIR=${OPTARG}
            ;;
        t)
            SEARCHING_TITLE=true
            QUERY_TITLE=${OPTARG}
            ;;
        f)
            FILE_4_SAVING_RESULTS=${OPTARG}
            ;;
        a)
            SEARCHING_ACTOR=true
            QUERY_ACTOR=${OPTARG}
            ;;
        x)
            OUTPUT_FORMAT="xml"
            ;;
        y)
            SEARCHING_YEAR=true
            QUERY_YEAR=${OPTARG}
            ;;
        R)
            SEARCHING_REGEX=true
            QUERY_REGEX=${OPTARG}
            ;;
        i)
            CASE_INSENSITIVE=true
            ;;
        \?)
            print_error "ERROR: Invalid option: -${OPTARG}"
            exit 1
            ;;
    esac
done

if ${PROVIDED_DIR:-false}; then
    if [[ ! -d "${MOVIES_DIR}" ]]; then
        echo Directory "${MOVIES_DIR}" not found
        exit 3
    fi
else
    echo -e "You did not provide a directory. Please use -d DIRECTORY_NAME to do so"
    exit 2
fi

MOVIES_LIST=$(get_movies_list "${MOVIES_DIR}")

if ${SEARCHING_TITLE:-false}; then
    MOVIES_LIST=$(query_title "${MOVIES_LIST}" "${QUERY_TITLE}")
fi

if ${SEARCHING_ACTOR:-false}; then
    MOVIES_LIST=$(query_actor "${MOVIES_LIST}" "${QUERY_ACTOR}")
fi

if ${SEARCHING_YEAR:-false}; then
    MOVIES_LIST=$(query_year "${MOVIES_LIST}" "${QUERY_YEAR}")
fi

if ${SEARCHING_REGEX:-false}; then
    if ${CASE_INSENSITIVE:-false}; then
        MOVIES_LIST=$(query_regex_nocase "${MOVIES_LIST}" "${QUERY_REGEX}")
    else
        MOVIES_LIST=$(query_regex "${MOVIES_LIST}" "${QUERY_REGEX}")
    fi
fi

if [[ "${#MOVIES_LIST}" -lt 1 ]]; then
    echo "Found 0 movies :-("
    exit 0
fi

if [[ "${FILE_4_SAVING_RESULTS:-}" == "" ]]; then
    print_movies "${MOVIES_LIST}" "${OUTPUT_FORMAT:-raw}"
else
    print_movies "${MOVIES_LIST}" "${OUTPUT_FORMAT:-raw}" | tee "${FILE_4_SAVING_RESULTS}"
fi