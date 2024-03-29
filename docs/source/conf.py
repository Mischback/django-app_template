# SPDX-License-Identifier: MIT

# Python imports
import datetime
import os
import sys

# Django imports
import django

# add the repositories root directory to the Python path
sys.path.insert(0, os.path.abspath("../../"))


import t3mpl4t3  # noqa: isort:skip


# for `autodoc`, Django has to be setup (with a minimal setup)
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "tests.util.settings_test")
django.setup()

# ### Project Information

project = t3mpl4t3.__app_name__
author = t3mpl4t3.__author__
copyright = "{}, {}".format(datetime.datetime.now().year, author)
version = t3mpl4t3.__version__
release = version


# ### General Configuration

# https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-exclude_patterns
exclude_patterns = []  # type: ignore[var-annotated]

# activate extensions
extensions = [
    # automatically insert labels for section titles
    "sphinx.ext.autosectionlabel",
    # make links to other, often referenced, sites easier
    "sphinx.ext.extlinks",
    # make graphviz available (needs system installation of graphviz)
    "sphinx.ext.graphviz",
    # provide links to other, sphinx-generated, documentation
    "sphinx.ext.intersphinx",
    # allow docstrings to be written in NumPy or Google style
    "sphinx.ext.napoleon",
    # automatic API documentation using the docstrings
    # HINT: Can be (temporarily) disabled to speed up build time!
    "autoapi.extension",
    # use the RTD theme
    # configuration is provided in the HTML Output section
    "sphinx_rtd_theme",
]

# "index" is already the default (since Sphinx 2.0), but better be explicit.
master_doc = "index"

modindex_common_prefix = ["t3mpl4t3."]

# https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-templates_path
templates_path = ["_templates"]

# https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-source_suffix
source_suffix = {
    ".rst": "restructuredtext",
    # ".txt": "restructuredtext",
}

# ### Extension Configuration

# ##### autosectionlabel
autosectionlabel_prefix_document = True
autosectionlabel_maxdepth = 2

# ##### autoapi
autoapi_type = "python"
autoapi_dirs = ["../../t3mpl4t3"]

# may be set to `False` when switching to manual directives, which is **hopefully* not necessary
autoapi_generate_api_docs = True

# https://sphinx-autoapi.readthedocs.io/en/latest/reference/config.html#confval-autoapi_options
# autoapi_options = ["members"]

# https://sphinx-autoapi.readthedocs.io/en/latest/reference/config.html#confval-autoapi_root
autoapi_root = "api"

autoapi_member_order = "groupwise"

# set the output format to "svg" to allow scaling; "png" is the alternative and default
graphviz_output_format = "svg"

# ##### intersphinx

django_version = ".".join(map(str, django.VERSION[0:2]))  # type: ignore[misc]
python_version = ".".join(map(str, sys.version_info[0:2]))
intersphinx_mapping = {
    "python": ("https://docs.python.org/" + python_version, None),
    "django": (
        "https://docs.djangoproject.com/en/{}/".format(django_version),
        "https://docs.djangoproject.com/en/{}/_objects/".format(django_version),
    ),
    # if the doc is hosted on RTD, the following should work out of the box:
    # "celery": ("https://celery.readthedocs.org/en/latest/", None),
}

# Python's docs don't change every week.
intersphinx_cache_limit = 90  # days


def _add_django_roles(app):  # type: ignore[no-untyped-def]
    """Adds Django-specific roles to be accessible while linking to Django's documentation.

    The roles are actually fetched from Django's own sphinx extension [1]_.

    .. [1] https://github.com/django/django/blob/master/docs/_ext/djangodocs.py
    """
    app.add_crossref_type(
        directivename="setting",
        rolename="setting",
        indextemplate="pair: %s; setting",
    )
    app.add_crossref_type(
        directivename="templatetag",
        rolename="ttag",
        indextemplate="pair: %s; template tag",
    )
    app.add_crossref_type(
        directivename="templatefilter",
        rolename="tfilter",
        indextemplate="pair: %s; template filter",
    )
    app.add_crossref_type(
        directivename="fieldlookup",
        rolename="lookup",
        indextemplate="pair: %s; field lookup type",
    )


# ##### extlinks
extlinks = {
    # will show commit's SHA1
    "commit": ("https://github.com/mischback/django-t3mpl4t3/commit/%s", "%s"),
    # will show "issue [number]"
    "issue": ("https://github.com/mischback/django-t3mpl4t3/issues/%s", "issue %s"),
    # A file or directory. GitHub redirects from blob to tree if needed.
    # will show file/path relative to root-directory of the repository
    "source": (
        "https://github.com/mischback/django-t3mpl4t3/blob/development/%s",
        "%s",
    ),
    # also available by intersphinx :django:doc:
    "djangodoc": (
        "https://docs.djangoproject.com/en/{}/%s".format(django_version),
        "%s",
    ),
    # also available by intersphinx (most likely as simple as specifying the full Python path)
    "djangoapi": (
        "https://docs.djangoproject.com/en/{}/ref/%s".format(django_version),
        "%s",
    ),
    # will show "Wikipedia: [title]"
    "wiki": ("https://en.wikipedia.org/wiki/%s", "Wikipedia: %s"),
}

# ### HTML Output

# set the theme
html_theme = "sphinx_rtd_theme"

html_theme_options = {
    # 'canonical_url': 'http://django-templ4t3.readthedocs.io',  # adjust to real url
    # 'analytics_id': 'UA-XXXXXXX-1',  #  Provided by Google in your dashboard
    # 'logo_only': False,
    # 'display_version': True,
    # 'prev_next_buttons_location': 'bottom',
    "style_external_links": True,  # default: False
    # 'vcs_pageview_mode': '',
    # 'style_nav_header_background': 'white',
    # Toc options
    # 'collapse_navigation': True,
    # 'sticky_navigation': True,
    # 'navigation_depth': 4,  # might be decreased?
    # 'includehidden': True,
    # 'titles_only': False
}

# https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-html_static_path
html_static_path = ["_static"]

# provide a logo (max 200px width)
# html_logo = ""


# ### Extension Magic


def setup(app):  # type: ignore[no-untyped-def]
    """Let this configuration be its own extension."""
    _add_django_roles(app)
