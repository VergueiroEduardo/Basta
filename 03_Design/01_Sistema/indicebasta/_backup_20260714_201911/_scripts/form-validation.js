/* ============================================================================
   FORM VALIDATION — Basta
   Validação leve client-side. Marca .form-input--error e mostra .form-error.
   Para validação de produção, usar React Hook Form + Zod no port para Next.js.
   ============================================================================ */
(function () {
  'use strict';

  function validateCPF(cpf) {
    cpf = cpf.replace(/\D/g, '');
    if (cpf.length !== 11) return false;
    if (/^(\d)\1+$/.test(cpf)) return false;
    var sum = 0, rest;
    for (var i = 1; i <= 9; i++) sum += parseInt(cpf.substring(i - 1, i)) * (11 - i);
    rest = (sum * 10) % 11;
    if (rest === 10 || rest === 11) rest = 0;
    if (rest !== parseInt(cpf.substring(9, 10))) return false;
    sum = 0;
    for (var j = 1; j <= 10; j++) sum += parseInt(cpf.substring(j - 1, j)) * (12 - j);
    rest = (sum * 10) % 11;
    if (rest === 10 || rest === 11) rest = 0;
    return rest === parseInt(cpf.substring(10, 11));
  }

  function showError(input, msg) {
    input.classList.add('form-input--error');
    var group = input.closest('.form-group') || input.parentNode;
    var err = group.querySelector('.form-error');
    if (!err) {
      err = document.createElement('p');
      err.className = 'form-error';
      err.setAttribute('role', 'alert');
      group.appendChild(err);
    }
    err.textContent = msg;
  }
  function clearError(input) {
    input.classList.remove('form-input--error');
    var group = input.closest('.form-group') || input.parentNode;
    var err = group.querySelector('.form-error');
    if (err) err.remove();
  }

  window.BastaValidation = {
    cpf: validateCPF,
    showError: showError,
    clearError: clearError
  };
})();
