#!/bin/bash

SOURCE_DIR=${1:-lab_uno}
RM_LIST=${2:-2remove}
TARGET_DIR=${3:-bakap}

if [[ ! -d "${TARGET_DIR}" ]]; then
    mkdir "${TARGET_DIR}"
fi

FILES=$(ls ${SOURCE_DIR})

for FILE in ${FILES}; do
    if  grep -q "${FILE}" "${RM_LIST}"; then
        if [[ -d "${SOURCE_DIR}/${FILE}" ]]; then
            rm -r "${SOURCE_DIR}/${FILE}"
        else
            rm "${SOURCE_DIR}/${FILE}"
        fi
    else
        if [[ -d "${SOURCE_DIR}/${FILE}" ]]; then
            cp -r "${SOURCE_DIR}/${FILE}" "${TARGET_DIR}"
        else
            cp "${SOURCE_DIR}/${FILE}" "${TARGET_DIR}"
        fi
    fi
done

COUNT=$(ls -1q "${SOURCE_DIR}" | wc -l)

if [[ "${COUNT}" -eq 0 ]]; then
    echo tu był Kononowicz
else
    echo Jeszcze coś zostało
    if [[ "${COUNT}" -gt 4 ]]; then
        echo Zostało więcej niż 4 pliki
    elif [[ "${COUNT}" -ge 2 ]]; then
        echo Zostały co najmniej 2 pliki
    fi
fi