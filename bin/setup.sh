!/bin/bash
if [ ! -f ./Lib_UNO/UNO.xml ]; then
  echo 'Cloning Lib_UNO repository'
  git clone git@github.com:TMContent/Lib_UNO.git
else
  echo 'Updating Lib_UNO repository'
  git pull origin master
fi
