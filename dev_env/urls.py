# SPDX-License-Identifier: MIT

"""Minimal URL Configuration for the development setup."""

# Django imports
from django.urls import include, path

# app imports
from tests.util.urls import urlpatterns

urlpatterns += [
    path("__debug__/", include("debug_toolbar.urls")),
]
