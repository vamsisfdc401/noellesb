declare module "@salesforce/apex/RST_ViewController.getApplicationSettings" {
  export default function getApplicationSettings(): Promise<any>;
}
declare module "@salesforce/apex/RST_ViewController.getWeeksAll" {
  export default function getWeeksAll(): Promise<any>;
}
declare module "@salesforce/apex/RST_ViewController.getPlayWeeksForWeek" {
  export default function getPlayWeeksForWeek(param: {weekSelected: any}): Promise<any>;
}
declare module "@salesforce/apex/RST_ViewController.getTitlesAll" {
  export default function getTitlesAll(): Promise<any>;
}
declare module "@salesforce/apex/RST_ViewController.sortingByFieldOfTittle" {
  export default function sortingByFieldOfTittle(param: {sortField: any, isAsc: any}): Promise<any>;
}
declare module "@salesforce/apex/RST_ViewController.setTitleLocked" {
  export default function setTitleLocked(param: {titleId: any, isLocked: any}): Promise<any>;
}
declare module "@salesforce/apex/RST_ViewController.setNestedPlayWeeks" {
  export default function setNestedPlayWeeks(param: {titleId: any, titlePlayWeek: any}): Promise<any>;
}
declare module "@salesforce/apex/RST_ViewController.getNestedPlayWeeks" {
  export default function getNestedPlayWeeks(param: {titleId: any}): Promise<any>;
}
