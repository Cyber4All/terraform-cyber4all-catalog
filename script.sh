set -e
myArray=("tflint" "terraform-fmt")

for str in ${myArray[@]}; do
  pre-commit run $str --all-files
done