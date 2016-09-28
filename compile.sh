#!/bin/bash

clear

# check handlebars
command -v handlebars > /dev/null
if [ $? -ne 0 ]; then
    echo -e "\033[31mErreur : handlebars n'est pas installé : sudo npm install DavidBabel/handlebars-cmd -g \033[39m"
    exit
fi

command -v comparejson > /dev/null
if [ $? -ne 0 ]; then
    echo -e "\033[31mErreur : comparejson n'est pas installé : sudo npm install compare-json -g \033[39m"
    exit
fi

command -v jsonlint > /dev/null
if [ $? -ne 0 ]; then
    echo -e "\033[31mErreur : jsonlint n'est pas installé : sudo npm install jsonlint -g \033[39m"
    exit
fi

# config
dest_folder="generated"
imgs_folder="images"
html_template="model.html"


cd "${0/\/compile.sh/}"


# validate json
echo -e "\033[36m  ================================== \033[39m"
echo -e "\033[36m =  vérification des fichiers JSON  = \033[39m"
echo -e "\033[36m  ================================== \033[39m"
echo ""
error=0
for lang_file in *.json; do
    test_error=`jsonlint ${lang_file} -q 2>&1`

    if [ -z "$test_error" ]; then
        echo -e "Fichier \033[32m${lang_file}\033[39m valide."
    else
        echo -e "Fichier \033[31m${lang_file}\033[39m non valide:"
        echo "${test_error}"
        error=1
    fi
done

if [ "$error" = 1 ]; then
        echo ""
        echo -e "\033[31mCorriger les erreurs pour pouvoir compiler\033[39m"
        echo ""
        echo "Appuyer sur 'Entrer' pour quitter"
        read end
        exit
fi
echo ""


# compare json
echo -e "\033[36m  ============================== \033[39m"
echo -e "\033[36m =  vérification des clés JSON  = \033[39m"
echo -e "\033[36m  ============================== \033[39m"
echo ""
comparejson *.json

# handlebars
rm -rf "./${dest_folder}"
mkdir "./${dest_folder}"

echo -e "\033[36m  ================================ \033[39m"
echo -e "\033[36m =  Compilation des fichier HTML  = \033[39m"
echo -e "\033[36m  ================================ \033[39m"
echo ""

for lang_file in *.json; do
    lang_code="${lang_file/.json/}"
    ## debug ##
    # echo $lang_code
    mkdir "${dest_folder}/${lang_code}"
    mkdir "${dest_folder}/${lang_code}/${imgs_folder}"
    ## debug ##
    # echo "handlebars ${lang_file} < model.html > ${lang_code}/${lang_code}.html"
    handlebars $lang_file --keep-missing < $html_template > "${dest_folder}/${lang_code}/${lang_code}.tmp.html"
    handlebars $lang_file --keep-missing < "${dest_folder}/${lang_code}/${lang_code}.tmp.html" > "${dest_folder}/${lang_code}/${lang_code}.html"
    rm "${dest_folder}/${lang_code}/${lang_code}.tmp.html"
    # node ../handlebars-cmd/index.js $lang_file --keep-missing < $html_template > "${dest_folder}/${lang_code}/${lang_code}.html"

    cp ./$imgs_folder/* "${dest_folder}/${lang_code}/${imgs_folder}" 2>>/dev/null
    if [ -d "./${imgs_folder}/${lang_code}/" ]; then
        cp ./${imgs_folder}/${lang_code}/* "${dest_folder}/${lang_code}/${imgs_folder}" 2>>/dev/null
    else
        echo -e "   -> Pas de dossier \033[31m${imgs_folder}/${lang_code}\033[39m trouvé"
    fi
    find_error=`grep -noh '{{.*}}' "./${dest_folder}/${lang_code}/${lang_code}.html"`
    if ! [[ -z "${find_error}" ]]; then
        echo -e "-> \033[33m${lang_file}\033[39m a rencontré une \033[31merreur\033[39m:"
        echo "   >  Des expressions manquantes ont été trouvées aux lignes suivantes :"
        echo "${find_error}"
    else
        echo -e "-> \033[33m${lang_file}\033[39m compilé en \033[32m${lang_code}/${lang_code}.html\033[39m"
    fi
done

echo ""
echo "Appuyer sur 'Entrer' pour quitter"
read end

