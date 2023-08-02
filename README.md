# Changelog Consolidator Git Hook

This repository contains a Git hook that automatically generates a changelog in markdown (`.md`) format for a specified branch. The hook is designed to run before a push to a specific release branch and extracts commit messages with ticket or issue numbers to create a categorized changelog.

## Usage

### Option 1: Using Git Submodule (Recommended)

To use this Git hook in your other repositories, follow these steps:

1. **Add the Hook as a Submodule**:

    Navigate to the root directory of your other repository and add the Git hook repository as a submodule:

    ```bash
    git submodule add https://github.com/ruuuyin/changelog-consolidator.git .git/hooks/changelog-consolidator
    ```

    This command adds the `changelog-consolidator` repository as a submodule under the ``.git/hooks/`` directory of your other repository. The submodule will be cloned into this directory.

2. **Commit the Submodule**:

    After adding the submodule, commit the changes to your repository to include the submodule:

    ```bash
    git add .gitmodules .git/hooks/changelog-consolidator
    git commit -m "Add changelog-consolidator submodule"
    ```

3. **Initialize Submodule**:

    When you clone your other repository or when others clone it, they need to initialize the submodule using:

    ```bash
    git submodule init
    git submodule update
    ```

    This will fetch the contents of the submodule and place the hook script inside the `.git/hooks/changelog-consolidator` directory of your other repository.

4. **Generate Changelog and Push**:

    Now, whenever you perform a push to the specified release branch in your other repository (e.g., **release/x.x.x**), the hook from the submodule will automatically generate a changelog in the root directory. After the changelog is updated, the push will proceed automatically.

### Option 2: Manually Copying the Hook Script

If you prefer not to use Git submodules, you can manually copy the hook script (`generate-changelog.sh`) into your `.git/hooks/` directory. This approach can be useful if you don't want to manage submodules or if you only need the hook in a single repository.

Follow these steps to manually copy the script:

1. **Download the Hook Script**

   Download the hook script from the Git hook repository:

   ```bash
   curl -O https://raw.githubusercontent.com/ruuuyin/changelog-consolidator/main/generate-changelog.sh
    ```

2. **Copy the Script to .git/hooks/ Directory**

   Copy the downloaded hook script into the **.git/hooks/**  directory of your other repository:

   ```bash
   cp generate-changelog.sh .git/hooks/pre-push
    ```

    **Note**: The hook script is renamed to pre-push (without the **.sh** extension) when copied to the .git/hooks/ directory.

3. **Make the Script Executable**

   Make the hook script executable:

   ```bash
   chmod +x .git/hooks/pre-push
    ```

4. **Generate Changelog and Push**

   Now, whenever you perform a push to the specified release branch in your other repository (e.g., **release/x.x.x**), the hook script will automatically generate a changelog in the specified directory. After the changelog is updated, the push will proceed automatically.

## Note

Regardless of the option you choose, please ensure that you follow semantic versioning and branch naming conventions to trigger the hook correctly. For example, the hook will be triggered for branches named **release/x.x.x**, where **x.x.x** represents the version number.
