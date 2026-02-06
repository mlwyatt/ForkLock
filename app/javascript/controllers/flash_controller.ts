import { Controller } from '@hotwired/stimulus';
import { typedController } from '@scripts/mixins/typescript_stimulus';

export default class extends typedController(Controller<HTMLElement>, {}) {
  dismiss(): void {
    this.element.remove();
  }
}
