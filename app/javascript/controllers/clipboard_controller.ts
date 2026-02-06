import { Controller } from '@hotwired/stimulus';
import { typedController } from '@scripts/mixins/typescript_stimulus';

const values = {
  text: String,
};

export default class extends typedController(Controller<HTMLElement>, { values }) {
  async copy(): Promise<void> {
    try {
      await navigator.clipboard.writeText(this.textValue);
      this.showFeedback();
    }
    catch {
      // Silent fail for clipboard operations
    }
  }

  private showFeedback(): void {
    const originalHTML = this.element.innerHTML;

    this.element.innerHTML = '<span class="icon"><i class="fas fa-check"></i></span><span>Copied!</span>';

    setTimeout(() => {
      this.element.innerHTML = originalHTML;
    }, 1500);
  }
}
