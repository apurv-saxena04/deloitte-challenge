import { LightningElement, api, track } from 'lwc';
import headerImage from '@salesforce/resourceUrl/reaGroupImage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSurveyResult from '@salesforce/apex/SurveyControllerHandler.createSurveyResult';

export default class SalesRepsSurvey extends LightningElement {
    @api recordId;
    @api spinner = false;
    @track currentStep;
    @track surveyPayload = [];

    firstName;
    lastName;

    finalText = 'thanks for your time. Press submit to submit your survey and be entered to win a free motorcycle! ';
    value;
    @track reaImageLogo = headerImage;

    get options() {
        return [
            { label: 'Very Poor', value: '1' },
            { label: 'Poor', value: '2' },
            { label: 'Average', value: '3' },
            { label: 'Good', value: '4' },
            { label: 'Excellent', value: '5' }
        ];
    }

    goToStepOne() {
        this.currentStep = '1';

        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template.querySelector('div.stepOne').classList.remove('slds-hide');
        this.template.querySelector('div.stepThree').classList.add('slds-hide');
    }

    goToStepTwo() {
        var inputFieldList = this.template.querySelectorAll('lightning-input-field');
        var foundErrors = false;
        inputFieldList.forEach(element => {
            if(element.required && !element.value){
                element.reportValidity();
                //this.displayToast('error','Please fill all the required fields','Error');
                foundErrors = true;
            }
        });
        if(!foundErrors){
            this.currentStep = '2';

            this.template.querySelector('div.stepOne').classList.add('slds-hide');
            this.template.querySelector('div.stepTwo').classList.remove('slds-hide');
            this.template.querySelector('div.stepThree').classList.add('slds-hide');
        }
        
    }

    goToStepThree() {
        var inputFieldList = this.template.querySelectorAll('lightning-input-field');
        var foundErrors = false;
        inputFieldList.forEach(element => {
            if(element.required && !element.value){
                element.reportValidity();
                //this.displayToast('error','Please fill all the required fields','Error');
                foundErrors = true;
            }
        });
        if(!foundErrors){
            this.currentStep = '3';
            this.template.querySelector('div.stepTwo').classList.add('slds-hide');
            this.template.querySelector('div.stepThree').classList.remove('slds-hide');
            this.template.querySelector('div.stepOne').classList.add('slds-hide');
        }
        
    }

    goBackHomePage() {
        this.currentStep = '1';

        this.template.querySelector('div.stepTwo').classList.add('slds-hide');
        this.template.querySelector('div.stepThree').classList.add('slds-hide');
        this.template.querySelector('div.stepOne').classList.remove('slds-hide');
        //this.refreshComponent();
    }

    refreshComponent(){
        eval("$A.get('e.force:refreshView').fire();");
    }

    handleRatingChange(event) {
        this.rating = event.detail.value;
        console.log('rating-->'+this.rating);
    }

    handleFirstNameChange(event){
        this.firstName = event.detail.value;
    }

    handleLastNameChange(event){
        this.lastName = event.detail.value;
    }

    //Generic method to display toast messages
    displayToast(typeStr, messageStr, titleStr){
        const event = new ShowToastEvent({
            title: titleStr,
            message: messageStr,
            variant: typeStr,
            mode: 'dismissable'
        });

        this.dispatchEvent(event);        

    }

    handleSave(){
        this.spinner = true;
        const firstName = this.template.querySelector('lightning-input-field[data-name="firstName"]').value;
        const lastName = this.template.querySelector('lightning-input-field[data-name="lastName"]').value;
        const email = this.template.querySelector('lightning-input-field[data-name="email"]').value;
        const customerType = this.template.querySelector('lightning-input-field[data-name="customerType"]').value;
        const rating = this.rating;
        const userId = this.template.querySelector('lightning-input-field[data-name="userId"]').value;
        const comment = this.template.querySelector('lightning-input-field[data-name="comment"]').value;
        
        this.surveyPayload.push({
            firstName : firstName,
            lastName : lastName,
            email : email,
            customerType : customerType,
            rating : rating,
            userId : userId,
            comment : comment,
        });

        console.log('surveyPayload--->'+JSON.stringify(this.surveyPayload));
        createSurveyResult({payload : JSON.stringify(this.surveyPayload), email: email})
        .then(result => {
            console.log('result on sending req-->'+JSON.stringify(result));
            console.log('result.includes("Error")'+result.includes("Error"));
            if(result.includes("Error")){
                this.displayToast('error',result,'Error');
            }else if(result.includes("successfully")){
                this.displayToast('success',result,'Success!!');
            }
            
            this.goBackHomePage();
            var inputFieldList = this.template.querySelectorAll('lightning-input-field');
            inputFieldList.forEach(element => {
                element.value = '';
            });
            this.spinner = false;
        })
        .catch(error => {
            this.spinner = false;
            this.displayToast('error','Please enter data for required fields','Error');
            console.log('Error while inserting survey-->'+JSON.stringify(error));
        })
    }
}