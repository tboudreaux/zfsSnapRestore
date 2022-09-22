#!/bin/bash

pools=$(zpool list -o name | sed -n '1!p')
allDataSets=()
for p in $pools; do
	datasets=$(zfs list -o name | sed -n '1!p' | grep "^$p")
	for dataset in $datasets; do
		childrenCheck="$(zfs list -o name,usedbychildren | sed -n '1!p' | egrep "$dataset\s" | awk '{split($0, a, " "); print a[2]}')"
		if grep -q "0B" <<< $childrenCheck; then
			dsName=$(echo $dataset | awk -F "/" '{print $NF}')
			allDataSets+=( $dsName )
		fi
	done
done
echo "Select which dataset to restore from"
select selectedDataset in ${allDataSets[@]}
do
	echo "Restoring From $selectedDataset"
	break
done

dsMountPoints=()
for p in $pools; do
	datasets=$(zfs list -o name,mountpoint | sed -n '1!p' | grep "^$p" | awk '{split($0, a, " ");print a[2]}')
	for dataset in $datasets; do
		dsMountPoints+=( "$(egrep "/$selectedDataset" <<< "$dataset")" )
	done
done
echo ${dsMountPoints[@]}



for mountPoint in ${dsMountPoints[@]}; do
	snapshotRootDir="$mountPoint/.zfs/snapshot"
	if [ -d $snapshotRootDir ]; then
		snapshots=($snapshotRootDir/*)
		# snapshotNames=($(find  ))
		select snapshotToRestore in ${snapshots[@]}
		do
			restorTag=$(echo $snapshotToRestore | awk -F "/" '{print $NF}')
			break
		done
	else
		echo "Error! $snapshotRootDir does not exist!"
		return 1
	fi
	vifm --choose-files "/tmp/zfssnapRestor.tmp" $snapshotToRestore 
	lines=0
	files=()
	while read p; do
		if [[ -d $p ]]; then
			echo "Ommiting $p as it is a directory"
		elif [[ -f $p ]]; then
			let "lines=lines+1"
			files+=( $p )
		else
			echo "Unknown error at $p!"
			exit
		fi
	done < "/tmp/zfssnapRestor.tmp"
	if [ "$lines" -eq "0" ]; then
		echo "No Files selected, exiting!"
		exit
	else
		echo "$lines file(s) staged to restore: "
		for file in ${files[@]}; do
			echo $file
		done
	fi
	echo "Finalize Restore?"
	select yn in "Yes" "No"; do
		case $yn in
			Yes) echo "Restoring..."; break;;
			No) echo "Canceling Restore!"; exit;;
		esac
	done
	for p in ${files[@]}; do
		restorLocation=$(sed "s@$snapshotToRestore@$mountPoint@g" <<< "$p")
		restorDir=$(dirname "${restorLocation}")
		baseFileName=$(basename -- $p)
		ext="${baseFileName##*.}"
		filename="${baseFileName%.*}"
		if grep -q "\." <<< $baseFileName; then
			restorPath="$restorDir/$filename.$restorTag.$ext"
		else
			restorPath="$restorDir/$filename.$restorTag"
		fi
		cp $p $restorPath
	done
	rm "/tmp/zfssnapRestor.tmp"
done

