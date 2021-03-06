# Fun with bash!
> Scripts that build your foundation in applying bash

- [About](#about)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Contributing](#contributing)
- [Licence](#Licence)
- [Contact](#contact)

## About

This repo contains packages that contain all the files you need to run the scripts discussed below

This is assuming you have Oracle VirtualBox and vagrant installed

Feel free to explore, reference, or play around with the code till you break it!

Not familiar with bash or any of the tools mentioned above? Worry not! In my [blog post](https://www.donisiko.com) 
I explore the steps in a little more detail, and also point out some of the amazing resources I 
took advantage of whilst learning to write these scripts myself!

### Creating User Accounts
The folder add-local-users explore writing scripts that automate the process of user account 
creation, disabling, and deletion.

You can imagine that in a large company with 10s if not 100s of employees, coming and going on a 
regular basis, automating the management of user accounts would result in more efficient use of
company resources.

### Multinet
The folder multinet explores scripting for a small network of servers. The basic setup is one 
admin server, followed by multiple subordinate servers. The admin server has a one way relationship
with the subordinate servers, in that it sends commands to them for execution, not the other way
around. Users of these scripts can send commands to the subordinate servers to execute

Again, the use cases for this set up are numerous, from automated configuration of N number of 
servers, scheduling installation/update of all connected servers/machines, co-ordination of the 
entire network from one source of truth; the list goes on.

Note: by default, this script works with the two VM's set out in the vagrant file, so these 
need to be running for these scripts to work as intended. if you wish to create your own VM's,
you need to modify Vagrantfile and run `vagrant up` again, then either add these new servers
to /etc/hosts or create a new server list containing the ip addresses of your new VM's 


---

## Getting Started

To run these scripts you simply need to:
1. download the folders
2. use the cd command in your terminal to set your current directory to a chosen folder
3. run the `vagrant up` command to start the virtual machines
4. use the `cd /vagrant` command to move to the mounted vagrant folder
5. run the script using `./script-name` or `sudo ./script-name` if root privilages required 
6. follow the usage instructions to learn how to use the scripts

---

## Usage

All scripts have a usage statement that should provide ample instructions, but should you find
yourself stuck, feel free to get in touch with me through twitter or email :)


---

## Contributing

1. Fork the project
2. Create a feature branch: `git checkout -b feature-branch`
3. Commit your changes: `git commit -am 'Added new features'`
4. Push your changes: `git push origin feature-branch`
5. Create a pull request

---

## Licence

Distributed under the MIT Licence.

---

## Contact

**Developer:** Don Isiko - thecodingdon@gmail.com

Repository Link: [https://github.com/Daoist-W/fun-with-bash](https://github.com/Daoist-W/fun-with-bash)