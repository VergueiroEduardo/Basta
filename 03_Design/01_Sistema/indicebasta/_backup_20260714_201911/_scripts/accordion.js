/* ============================================================================
   ACCORDION — Basta
   Universal handler para .accordion. Suporta keyboard (Enter, Space).
   Usar com .accordion__header como botão (use <button> ou role="button").
   ============================================================================ */
(function () {
  'use strict';

  function toggleAccordion(accordion) {
    var isOpen = accordion.classList.toggle('is-open');
    var header = accordion.querySelector('.accordion__header');
    if (header) {
      header.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    }
  }

  function init() {
    document.querySelectorAll('.accordion').forEach(function (acc) {
      var header = acc.querySelector('.accordion__header');
      if (!header) return;

      // Garante role+aria mesmo se markup vier incompleto
      if (header.tagName !== 'BUTTON' && !header.hasAttribute('role')) {
        header.setAttribute('role', 'button');
      }
      if (!header.hasAttribute('tabindex') && header.tagName !== 'BUTTON') {
        header.setAttribute('tabindex', '0');
      }
      if (!header.hasAttribute('aria-expanded')) {
        header.setAttribute('aria-expanded', acc.classList.contains('is-open') ? 'true' : 'false');
      }

      header.addEventListener('click', function () {
        toggleAccordion(acc);
      });

      header.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          toggleAccordion(acc);
        }
      });
    });
  }

  // Compatibilidade com onclick="toggle('id')" legado
  window.toggle = function (id) {
    var node = document.getElementById(id);
    if (!node) return;
    var acc = node.closest('.accordion') || node;
    var isOpen = acc.classList.toggle('is-open');
    var header = acc.querySelector('.accordion__header') || acc;
    if (header.setAttribute) {
      header.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    }
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
