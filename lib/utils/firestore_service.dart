String traducirErrorFirebase(String? codigo) {
  switch (codigo) {
    case 'invalid-email':
      return 'Correo electrónico no válido.';
    case 'user-disabled':
      return 'Esta cuenta ha sido deshabilitada.';
    case 'user-not-found':
      return 'No se encontró una cuenta con ese correo.';
    case 'wrong-password':
      return 'Contraseña incorrecta.';
    case 'email-already-in-use':
      return 'El correo ya está registrado.';
    case 'operation-not-allowed':
      return 'Esta operación no está permitida.';
    case 'weak-password':
      return 'La contraseña es demasiado débil.';
    default:
      return 'Ocurrió un error. Intenta de nuevo.';
  }
}
