# SPDX-License-Identifier: MIT

"""Provides the means to run the app within a minimal Django project."""

# Django imports
from django.conf import settings


def callback_show_debug_toolbar(request):
    """Return ``settings.DEBUG`` to control debug_toolbar."""
    return settings.DEBUG
