!/bin/bash
if [ ! -f ./Lib_UNO/UNO.xml ]; then
  echo 'Cloning Lib_UNO repository'
  git clone git@github.com:TMContent/Lib_UNO.git
  git clone git@github.com:tm-build/Lib_UNO-json.git
else
  echo 'Updating Lib_UNO repository'
  git pull origin master
  cd Lib_UNO-json
  git pull origin master
  cd ..
fi
