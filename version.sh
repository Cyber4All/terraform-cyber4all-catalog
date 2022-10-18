help_usage() {
  echo "Version - Manages Project version\n"
  echo "Version [options] [arguments]\n"
  echo "options:"
  echo "-h                show brief help"
  echo "-r                read the version of the project"
  echo "-w                write the new SEMVER of the project\n"
}

FILE=version.txt

read_file() {
  if [ -f "$FILE" ]; then
    echo "$(cat $FILE)"
  else
    exit 1
  fi
}

write_version() {
  REGEX="[0-9].[0-9].[0-9]"
  if echo $1 | grep -Eq $REGEX; then
    echo "$1" > $FILE
    if [ $(cat $FILE) = $1 ]; then
      echo "Succesfully Updated Version to $1"
    else
      echo "Failed Updating Version to $1"
    fi
  else
    echo "Version must follow SEMVER conventions '$REGEX'"
  fi
}

while getopts 'hrw:' flag; do
  case "${flag}" in
    h)
      help_usage
      exit 0
      ;;
    r)
      read_file
      exit 0
      ;;
    w) 
      write_version $OPTARG
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

echo "Use -h | --help to print the usage"