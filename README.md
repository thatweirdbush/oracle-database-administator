# Projects - Data Security In Information Systems
## Build Instruction:
#### 1. Update `Visual Studio` to the latest version.
#### 2. Download `Extension Oracle Developer Tools For Visual Studio 2022`:
* #### Extensions → Manage Extensions → Online → Enter the extension name above.
#### 3. Download `.NET Framework 4.8.1 Developer Pack` from the following link.
* #### Run the `.exe` file just downloaded.
#### 4. Download the latest version of `ODAC 21c Xcopy Packages` at the following link.
* #### Unzip the zip file.
* #### Open `Command Line`, enter the `cd` command to the folder containing the above file.
* #### Enter `install.bat all <path to the folder you want to save> myhome true`
* #### For example: `install.bat all C:\Oracle\ODAC myhome true`


## Run Instruction:
#### Run `Oracle Database Administator.exe` file in `bin/Debug` folder.


## Describe functions:
## Sub-System 1: Oracle Database Management Application.
### Users with administrative rights on Oracle DB Server can perform the following operations:
#### 1. View the list of user accounts in the Oracle DB Server system.
#### 2. View information about the rights (privileges) of each user/role on data objects.
#### 3. Allows `Insert`, `Delete`, `Update`  users or roles.
#### 4. Allows granting permissions:
* #### Grant permissions to users, grant permissions to roles, grant roles to users.
* #### The authorization process has the option to allow the grantee to grant that permission to another user/role or not (specify `WITH GRANT OPTION` or not).
* #### `Select` and `Update` privilege must allow decentralization up to the column level; `Insert` and `Delete` permissions are not allowed.
* #### Revoke permissions from user/role.
* #### Allows checking the rights of subjects who have just been granted rights.
##


## Sub-System 2: Internal Data Management Application
### Requirement 1: Grant access.
* #### Using `DAC`
* #### Using `RBAC`
* #### Using `VPD`
### Requirement 2: Apply the OLS access control model.
* #### Set up a 3-component label system and adjust the data model (if necessary) so that the system can meet the following requirements.
* #### The content of the announcement often depends on the field of activity of the relevant departments, including: `HTTT, CNPM, KHMT, CNTT, TGMT, MMT`.
### Requirement 3: System logging.
* #### Enable system logging.
* #### Perform system logging using `Standard Audit`.
* #### Perform system logging using `Fine-grained Audit`.
* #### Check (read output) the system log data.

### Requirement 4: Backup and restore data.
* #### Implement data backup and recovery mechanism provided by DBMS.
* #### Install backup functions (active, automatic) and restore data based on system logs in Requirement 3.
