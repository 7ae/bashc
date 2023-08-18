
#!/bin/bash
# Strong Random Password Generator
# Generates a strong random password containing alphanumeric and special characters.
# Usage: ./pass.sh <num>
#   <num> - Number of the password to be generated (an integer greater than 0)
#
# strong random password generator
length=$1
[ -z $1 ] && {
  echo "Usage: pass <length>" 2>/dev/null; exit 1;
}
[ $1 -eq $1 2>/dev/null ] && [ $1 -ge 0 ] || {
  echo "Argument must be an integer greater than 0:" $1 2>/dev/null; exit 1;
}
for i in {1..100}
do
  cat /dev/urandom | tr -dc 'a-zA-Z0-9`~!@#$%^&*()[]{}<>_+-=.,:;'\''"/|\\?' | head -c $length; echo; echo;
done

