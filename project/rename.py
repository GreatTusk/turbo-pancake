import os


def rename_folders_to_lowercase(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir, topdown=False):
        for dirname in dirnames:
            old_path = os.path.join(dirpath, dirname)
            new_path = os.path.join(dirpath, dirname.lower())
            if old_path != new_path:
                os.rename(old_path, new_path)


# Call the function with the root directory
rename_folders_to_lowercase('.')
