# === This script creates a user account under Mac OS X === #
echo "Please enter new user's details."
read -p "Username: " USERNAME
read -p "Full Name: " FULLNAME
read -p "Password: " PASSWORD
read -p "Admin? (y/n): " USRTYPE

# ========================================================= #

if [[$USRTYPE -eq y]]; 
	then
		ADMIN="admin _lpadmin _appserveradm _appserverusr";
	else
		ADMIN="";
fi

if [[ $UID -ne 0 ]];
 then
	echo "Please run $0 as root." && exit 1;
fi

# Find out the next available user ID
MAXID=$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)
USERID=$((MAXID+1))

# Create the user account
dscl . -create /Users/$USERNAME
dscl . -create /Users/$USERNAME UserShell /bin/bash
dscl . -create /Users/$USERNAME RealName "$FULLNAME"
dscl . -create /Users/$USERNAME UniqueID "$USERID"
dscl . -create /Users/$USERNAME PrimaryGroupID 20
dscl . -create /Users/$USERNAME NFSHomeDirectory /Users/$USERNAME

dscl . -passwd /Users/$USERNAME $PASSWORD


# Add use to any specified groups
for GROUP in $ADMIN ; do
	dseditgroup -o edit -t user -a $USERNAME $GROUP
done

# Create the home directory
createhomedir -c 2>/dev/null

echo "Created $USERNAME ($FULLNAME) :)"