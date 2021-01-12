export class UserLoginModel {
    constructor(userName?: string, password?: string, rememberMe?: boolean) {
        this.userName = userName;
        this.password = password;
        this.rememberMe = rememberMe;
    }

    userName: string;
    password: string;
    rememberMe: boolean;
}

export enum AuthProviders {
  IdentityServer,
  Google,
  Microsoft,
  Facebook,
  Twitter,
  GitHub
}
