
# Reason Manager for Managers (RMM)

Allows the user to manage their own reasons for package installing.

A problem i always dealt with while mantaining a Linux, or any Language in general (Python/Node) is installing a package for a use, using it (or sometimes not even using) and just forgetting why it's there, or that it is there at all.

The main goal of the application is a simple nudge for the user, into making him declare why he would be installing something.

The call will be structured as < Config > < install call > < stuff to install > < commit message >

$ RMM install "sudo pacman -S" "nvim tree git" "edit code more efficiently"

The command will refuse to work unless all fields are filled.

After the call, all it does is install the stuff you wanted, write your install historic as a install.bash and also as a .rmm.db.

You can then look the reasons up using:

$ RMM reason nvim tree git 

And it will display the reasons for installation and deinstallation for all items.
It will say 'Reason for < stuff > unknown' if you ask for something you dont have in.

You can also remove stuff using:

$ RMM uninstall "sudo pacman -Rs" "nvim tree git" "i quit my course :("

And it will automatically remove all stuff cited from install.bash and add your reason concatenated with the previous reason on the db file.
This is useful so, if you ever wonder why a thing is actually not there, you can 'RMM reason' the name and remember why.

Using 'RMM install/uninstall' will always also show the message for any package you already have, what makes all RMM commands comport like the 'reason' one. You will always be forced to see the reasons that the system knows about your stuff, even if youre reinstalling, even if youre removing. and you could see something like this eventually:

$ RMM install "sudo pacman -S" "nvim" "i cant bother to use vscode man"
> Nvim: edit code more efficiently <REMOVED> i quit my course :( <REINSTALLED> i want to go back to my course now, i love CS <REMOVED> i am going to vscode

The system will have its own folder, that must be linked on .local/bin to be able to be called. And it will also have a .git folder.
As the system will commit itself with the < commit message > always, so you can keep track of it. And even push to github eventually if you want.
