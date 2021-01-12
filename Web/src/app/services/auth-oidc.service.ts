import { Injectable } from '@angular/core';
import * as Auth from 'angular-oauth2-oidc';
import { NgZone } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable()
export class AuthOidcService extends Auth.OAuthService {
  private accessToken: string;

  constructor(ngZone: NgZone, http: HttpClient, storage: Auth.OAuthStorage, tokenValidationHandler: Auth.ValidationHandler, config: Auth.AuthConfig, urlHelper: Auth.UrlHelperService, logger: Auth.OAuthLogger) {
    super(ngZone, http, storage, tokenValidationHandler, config, urlHelper, logger, null);
  }

  getParamsObjectFromHash() {
    const hash = window.location.hash ? window.location.hash.split('#') : [];
    let toBeReturned = {};
    if (hash.length && hash[1].split('&').length) {
      toBeReturned = hash[1].split('&').reduce((acc, x) => {
        const hello = x.split('=');
        if (hello.length === 2) acc[hello[0]] = hello[1];
        return acc;
      }, {});
    }
    return Object.keys(toBeReturned).length ? toBeReturned : null;
  }

  //getAccessToken(): string {
  //  return super.getAccessToken() || this.accessToken;
  //}
}
