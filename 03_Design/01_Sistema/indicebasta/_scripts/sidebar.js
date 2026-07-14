/* ============================================================================
   SIDEBAR + LOGOUT MODAL — Basta
   - Marca link ativo via data-page no <body> (ex.: <body data-page="dashboard">)
   - Toggle do logout modal (openLogout, closeLogout, confirmLogout)
   - Fecha modal com Escape
   ============================================================================ */
(function () {
  'use strict';

  function markActive() {
    var page = document.body.getAttribute('data-page');
    if (!page) return;
    document.querySelectorAll('.sidebar .nav-item[data-page="' + page + '"]').forEach(function (link) {
      link.classList.add('nav-item--active');
      link.setAttribute('aria-current', 'page');
    });
  }

  function lockScroll(lock) {
    document.body.style.overflow = lock ? 'hidden' : '';
  }

  window.openLogout = function () {
    var m = document.getElementById('logoutModal');
    if (!m) return;
    m.classList.add('is-open');
    lockScroll(true);
    var firstBtn = m.querySelector('button');
    if (firstBtn) firstBtn.focus();
  };
  window.closeLogout = function () {
    var m = document.getElementById('logoutModal');
    if (!m) return;
    m.classList.remove('is-open');
    lockScroll(false);
  };
  window.confirmLogout = function () {
    // produção: chamar Supabase signOut
    window.location.href = '03_basta-login.html';
  };

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      var m = document.getElementById('logoutModal');
      if (m && m.classList.contains('is-open')) window.closeLogout();
    }
  });

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', markActive);
  } else {
    markActive();
  }
})();
