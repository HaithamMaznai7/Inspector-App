enum AccounStatus {
  active,
  inactive,
  passwordReset,
  created;

  factory AccounStatus.set(String? value) {
    value = value?.toLowerCase();

    switch (value) {
      case 'active':
        return AccounStatus.active;
      case 'resetpassword':
        return AccounStatus.passwordReset;
      case 'created':
        return AccounStatus.created;
      default:
        return AccounStatus.inactive;
    }
  }
}
