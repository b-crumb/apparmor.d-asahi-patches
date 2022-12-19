## apparmor-asahi-patches

This is a BIG WIP.

Every folder BUT `succeeding-boot-disable/` has incomplete profiles adjusted for Asahi Linux devices (it will probably break anything but an M1 pro for now) (and adjusted for ALARM, also in general ARCH package tidbits).

`succeeding-boot-disable/` is currently filled out as such because on an M1 it SHOULD allow boot to proceed, but without internet currently.

`disable/` is for the actual disables which are required at MINIMUM.

Expect that this WILL break your system in some way.

### Contributing

You contribute by breaking your system.

Setup:

1. Kernel must support apparmor (default Asahi does).
2. Add Apparmor kernel args `lsm=landlock,lockdown,yama,integrity,apparmor,bpf apparmor.debug=1` and rebuild stuff.
3. Build the `apparmor.d-git` package.
4. `pacman -S apparmor`. Start the service!
5. `pacman -U` it (FOLLOW THEIR INSTRUCTIONS ON GITHUB).
6. `systemctl enable apparmor`.
7. Have a side Asahi install ready in case you need to mount & disable Apparmor.

(did I miss anything?)

Contributing:

1. `shutdown -h now`.
2. Boot, if boot does not work, use the side install and disable the thing. 
  * Find out what caused the freeze by disabling profiles. For example, you can binary "search" the bottom half of the profiles (abc sorted) `find . -maxdepth 1 -not -type d | sort -h | tail -n 556 | xargs ln -rst disable` (there is I think exactly 1030 profiles in total).
  * `aa-log | grep DENIED` might also help, this helps more though if boot was successful.
3. Disable profiles you can't fix. Add those really needed disable (and not convenience `succeeding-boot-disable/`) to `disable`.
4. Only add changes to `local` or `.d` files in the other subfolders, except the disable folders of course.

Main pain points:

1. Firmware and identifying what profiles are using it. This is due to different filepaths.
2. Arch / ALARM package filepath differences (meaning, both arch in comparison to apparmor.d and I guess ALARM).

Happy contributing!
