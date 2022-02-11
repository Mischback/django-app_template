# django-app_template

This is a template repository to set up a repository for development of
pluggable [Django](https://www.djangoproject.com) applications.

## Recommended Usage

1. Create a new repository on GitHub, using this as the template. Do not
   include all branches. Give the repository a matching name, by convention
   Django applications are named ``django-[appname]``.

2. Clone the repository to your local machine

   ```bash
   $ git clone [REPO URL]
   $ cd django-[appname]
   ```

3. You should find yourself on the ``development`` branch. Create your actual
   release branch now (to keep things tidy).

   ```bash
   $ git branch main
   ```

4. Setup the ``pre-commit`` hooks:

   ```bash
   $ make util/pre-commit/install
   ```

5. Time to convert the template into your very own app. Start by replacing all
   occurences of ``t3mpl4t3`` with fitting values (this will be your
   ``[appname]`` for most cases).

   ```bash
   $ git checkout -b chore-template-adjustment
   $ git mv t3mpl4t3 [appname]
   $ git commit -am "Rename actual app directory"
   ```

   This command sequence will create a new branch, rename the actual app
   directory and commit the change. Now to the files! The following command
   will find all occurences of ``t3mpl4t3`` and should suffice as a reference.

   ```bash
   $ make util/repo/template
   ```

   Replace all occurences, until the make recipe results in an empty output.

   **Pay special attention** to ``.github/workflows/ci-release.yml``. In this
   file the occurence of ``t3mpl4t3`` has to be replaced with the name of your
   release branch (see step 3).

   It is **highly recommended** to go file by file and commmit on every
   updated file.

6. When completed, push the branch to GitHub, raise a pull request, let the
   CI finish and then "squash merge" from GitHub's web interface.

   Then use

   ```bash
   $ git fetch
   $ git checkout development
   $ git merge --ff origin/development
   ```
7. **Finished**, go ahead and create something special!
