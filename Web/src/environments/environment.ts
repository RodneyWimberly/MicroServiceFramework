import { AppModule } from '../app/app.module';
import { Injectable, Inject, InjectionToken } from '@angular/core';


// This file can be replaced during build by using the `fileReplacements` array.
// `ng build --prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.



export const environment = {
  production: false,
  webBaseUrl: 'https://localhost:60000',
  authorityBaseUrl: 'https://localhost:6002', 
  apiBaseUrl: 'https://localhost:6001/api',
  apiVersion: '1.0',
  loginUrl: '/login',
  authCallbackUrl: 'https://localhost:60000/callback'
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
import 'zone.js/dist/zone-error';  // Included with Angular CLI.
