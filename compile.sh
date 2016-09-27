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

# config
dest_folder="generated"
imgs_folder="images"
html_template="model.html"


cd ${0/\/compile.sh/}

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
    handlebars $lang_file --keep-missing < $html_template > "${dest_folder}/${lang_code}/${lang_code}.html"
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

