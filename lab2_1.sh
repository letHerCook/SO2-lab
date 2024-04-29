#!/bin/bash -eu

DIR=${1}


if [[ ! -d "${DIR}" ]]; then
    echo Nie ma takiego katalogu
    exit
fi

FILES=$(ls ${DIR})

for FILE in ${FILES}; do
    if [[ "${FILE}" == *.bak ]]; then
        if [[ -f "${DIR}/${FILE}" ]]; then  
            chmod u-w,g-w,o-w "${DIR}/${FILE}"
        elif [[ -d "${DIR}/${FILE}" ]]; then
            chmod u+r,g+x,o+rx "${DIR}/${FILE}"
            chmod u-x,g-r "${DIR}/${FILE}"
        fi
    elif [[ "${FILE}" == *.tmp ]]; then
        if [[ -d "${DIR}/${FILE}" ]]; then
            chmod o+t "${DIR}/${FILE}"
        fi
    elif [[ "${FILE}" == *.txt ]]; then
        chmod u=w,g=r,o=x "${DIR}/${FILE}"
    fi
done