# zfsSnapRestore
Utility for easily restoring files from zfs snapshots

## Installation
All you should have to do is put this script in your path

## Usage

```bash
zfsSnapRestore.sh
```

This will bring up a list of datasets. Each one will show a name and a number.
Select the dataset you would like to restore from by entering its number

Next you will see a list of snapshots, again enter the number of the snapshot
you would like to restore from. Note that this list can get quite long and the
ease to which you will be able to navigate it is dependent on how well you have
named your snapshots (most auto snapshot Utilities do an okay job at this).

Once you have selected a snapshot you will be thrown into a curses based file
manager. Browse to the file(s) you want to restore using the arrow and enter
keys. Then select the file(s) you want to restore by placing the cursor over
them and hitting the t key. Once you have select all the files you want hit
enter over one of those files.

Now those files will be restored to the same location they were in in the
snapshot but with their file names changed so that indicate they are a snap
restore and what snap they came from.

## Notes
This is a script I use regually on my server and others may find it helpful;
however, this is not something which I set out to maintain. Therefore, I will
fix bugs as they affect me or as I have time. Do be aware however, that this
may not work out of the box on your setup.
