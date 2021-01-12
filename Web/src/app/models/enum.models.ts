export enum GenderEnumModel {
    None,
    Female,
    Male
}

export enum ViewModelStates {
  New,
  Edit,
  View,
  Delete
}

export type AuthProvidersModel =
  'none' |
  'idsvr' |
  'implict' |
  'google' |
  'microsoft' |
  'facebook' |
  'twitter'
