/* ============================================================================
   INPUT MASKS — Basta
   CPF, CNPJ, CEP, telefone, data, moeda BRL.
   Uso:
     <input data-mask="cpf">
     <input data-mask="cep">
     <input data-mask="phone">
     <input data-mask="date">
     <input data-mask="currency">
   ============================================================================ */
(function () {
  'use strict';

  var masks = {
    cpf: function (v) {
      v = v.replace(/\D/g, '').slice(0, 11);
      return v
        .replace(/(\d{3})(\d)/, '$1.$2')
        .replace(/(\d{3})(\d)/, '$1.$2')
        .replace(/(\d{3})(\d{1,2})$/, '$1-$2');
    },
    cnpj: function (v) {
      v = v.replace(/\D/g, '').slice(0, 14);
      return v
        .replace(/^(\d{2})(\d)/, '$1.$2')
        .replace(/^(\d{2})\.(\d{3})(\d)/, '$1.$2.$3')
        .replace(/\.(\d{3})(\d)/, '.$1/$2')
        .replace(/(\d{4})(\d{1,2})$/, '$1-$2');
    },
    cep: function (v) {
      v = v.replace(/\D/g, '').slice(0, 8);
      return v.replace(/(\d{5})(\d)/, '$1-$2');
    },
    phone: function (v) {
      v = v.replace(/\D/g, '').slice(0, 11);
      if (v.length <= 10) {
        return v.replace(/(\d{2})(\d{4})(\d)/, '($1) $2-$3');
      }
      return v.replace(/(\d{2})(\d{5})(\d)/, '($1) $2-$3');
    },
    date: function (v) {
      v = v.replace(/\D/g, '').slice(0, 8);
      return v
        .replace(/(\d{2})(\d)/, '$1/$2')
        .replace(/(\d{2})(\d)/, '$1/$2');
    },
    currency: function (v) {
      v = v.replace(/\D/g, '');
      if (!v) return '';
      var n = parseInt(v, 10) / 100;
      return n.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
    }
  };

  function applyMask(input) {
    var type = input.getAttribute('data-mask');
    var fn = masks[type];
    if (!fn) return;
    input.addEventListener('input', function () {
      var pos = input.selectionStart;
      input.value = fn(input.value);
      // tenta restaurar caret no final dos dígitos
      try { input.setSelectionRange(input.value.length, input.value.length); }
      catch (_) { /* alguns input types não suportam */ }
    });
  }

  function init() {
    document.querySelectorAll('input[data-mask]').forEach(applyMask);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // Expor para uso programático
  window.BastaMasks = masks;
})();
