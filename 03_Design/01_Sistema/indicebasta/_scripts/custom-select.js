/* ============================================================================
   CUSTOM SELECT acessível — Basta
   Usar com .custom-select markup:
     <div class="custom-select">
       <button class="custom-select__trigger" aria-haspopup="listbox" aria-expanded="false">
         <span class="custom-select__value">Todos os bancos</span>
         <svg class="custom-select__chevron">…</svg>
       </button>
       <ul class="custom-select__listbox" role="listbox">
         <li role="option" aria-selected="true">Todos</li>
         <li role="option">Nubank</li>
         …
       </ul>
     </div>
   ============================================================================ */
(function () {
  'use strict';

  function initSelect(root) {
    var trigger = root.querySelector('.custom-select__trigger');
    var listbox = root.querySelector('.custom-select__listbox');
    var valueEl = root.querySelector('.custom-select__value');
    if (!trigger || !listbox) return;

    var options = Array.prototype.slice.call(root.querySelectorAll('.custom-select__option, [role="option"]'));
    var activeIndex = options.findIndex(function (o) { return o.getAttribute('aria-selected') === 'true'; });
    if (activeIndex < 0) activeIndex = 0;

    function open() {
      root.classList.add('is-open');
      trigger.setAttribute('aria-expanded', 'true');
      var active = options[activeIndex];
      if (active) active.focus();
    }
    function close() {
      root.classList.remove('is-open');
      trigger.setAttribute('aria-expanded', 'false');
    }
    function toggle() {
      if (root.classList.contains('is-open')) close(); else open();
    }
    function pick(opt) {
      options.forEach(function (o) { o.setAttribute('aria-selected', 'false'); o.classList.remove('custom-select__option--active'); });
      opt.setAttribute('aria-selected', 'true');
      opt.classList.add('custom-select__option--active');
      if (valueEl) valueEl.textContent = opt.textContent.trim();
      activeIndex = options.indexOf(opt);
      close();
      trigger.focus();
      // dispara evento custom para o consumidor
      root.dispatchEvent(new CustomEvent('change', { detail: { value: opt.dataset.value || opt.textContent.trim() }, bubbles: true }));
    }

    trigger.addEventListener('click', toggle);
    trigger.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowDown' || e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        open();
      }
    });

    options.forEach(function (opt, i) {
      // garantir que cada opção é focável
      if (!opt.hasAttribute('tabindex')) opt.setAttribute('tabindex', '-1');
      opt.addEventListener('click', function () { pick(opt); });
      opt.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); pick(opt); }
        else if (e.key === 'ArrowDown') { e.preventDefault(); var n = options[(i + 1) % options.length]; if (n) n.focus(); }
        else if (e.key === 'ArrowUp')   { e.preventDefault(); var p = options[(i - 1 + options.length) % options.length]; if (p) p.focus(); }
        else if (e.key === 'Escape')    { e.preventDefault(); close(); trigger.focus(); }
        else if (e.key === 'Home')      { e.preventDefault(); options[0].focus(); }
        else if (e.key === 'End')       { e.preventDefault(); options[options.length - 1].focus(); }
      });
    });

    document.addEventListener('click', function (e) {
      if (!root.contains(e.target)) close();
    });
  }

  function init() {
    document.querySelectorAll('.custom-select').forEach(initSelect);
  }

  // Compatibilidade legado
  window.pickOption = function (el) {
    var root = el.closest('.custom-select');
    if (!root) return;
    var opts = root.querySelectorAll('.custom-select__option');
    opts.forEach(function (o) { o.classList.remove('custom-select__option--active'); o.setAttribute('aria-selected', 'false'); });
    el.classList.add('custom-select__option--active');
    el.setAttribute('aria-selected', 'true');
    var valueEl = root.querySelector('.custom-select__value');
    if (valueEl) valueEl.textContent = el.textContent.trim();
    root.classList.remove('is-open');
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
