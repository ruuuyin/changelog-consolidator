#!/bin/sh

current_branch="$(git rev-parse --abbrev-ref HEAD)"
branch_basis="release"
changelog_dir="changelogs"

if [[ $current_branch != $branch_basis* ]]; then
    exit 0
fi

if [ ! -d "$changelog_dir" ]; then
    # Create the directory
    mkdir "$changelog_dir"
    echo "Directory created: $changelog_dir"
fi

# Split the branch name and get the version
OLD_IFS=$IFS
IFS='/'
read -ra split_release <<< "$current_branch"

version="${split_release[1]}"
IFS='.' read -r major_version minor_version patch_version <<< "$version"
IFS=$OLD_IFS

padded_major_version=$(printf "%02d" "$major_version")
padded_minor_version=$(printf "%02d" "$minor_version")
padded_patch_version=$(printf "%03d" "$patch_version")

compressed_version="${padded_major_version}${padded_minor_version}${padded_patch_version}"

extract_ticket(){
    echo "$1" | grep -oE '\[#([0-9]+)\].*' | tr -d '[' | tr -d ']'
}

generate_changelog(){
    changelog_file="${changelog_dir}/version-${compressed_version}.md"

    if [ -f "$changelog_file" ]; then
        echo "Changelog file ${changelog_file} already exists. Skipping changelog generation."
    fi

    echo "# Changelog for Release ${version}\n" > "$changelog_file"

    commit_hashes=$(git rev-list "origin/main..$current_branch")

    fixed=""
    added=""
    removed=""
        
    for hash in $commit_hashes; do
        commit_msg=$(git log --format="%s" -n 1 "$hash")
        ticket_info=$(extract_ticket "$commit_msg")
            
        # Check if commit message contains "Fix," "Add," or "Removed" and categorize accordingly
        if echo "$commit_msg" | grep -qiE '\[#[0-9]+\][[:space:]]+Fix[[:space:]]*\|'; then
            fixed="${fixed}- ${ticket_info}\n"
        elif echo "$commit_msg" | grep -qiE '\[#[0-9]+\][[:space:]]+Add[[:space:]]*\|'; then
            added="${added}- ${ticket_info}\n"
        elif echo "$commit_msg" | grep -qiE '\[#[0-9]+\][[:space:]]+Remove[[:space:]]*\|'; then
            removed="${removed}- ${ticket_info}\n"
        fi
    done
        
    # Add the categorized sections to the changelog file using printf
    if [ -n "$fixed" ]; then
        printf "## Fixed\n${fixed}\n" >> "$changelog_file"
    fi
        
    if [ -n "$added" ]; then
        printf "## Added\n${added}\n" >> "$changelog_file"
    fi
        
    if [ -n "$removed" ]; then
        printf "## Removed\n${removed}\n" >> "$changelog_file"
    fi

    git add "$changelog_file"
    git commit -m "Compile changelog for Release $version"
    echo "Changelog updated for branch ${current_branch}. Proceeding with the push..."
}


# Hook entry point
while read -r local_ref local_sha remote_ref remote_sha; do
    if [ "$remote_ref" = "refs/heads/${current_branch}" ]; then
        generate_changelog
        break
    fi
done

exit 0


