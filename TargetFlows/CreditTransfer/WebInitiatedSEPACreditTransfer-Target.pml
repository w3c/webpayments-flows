@startuml
!includeurl https://raw.githubusercontent.com/w3c/webpayments-flows/gh-pages/PaymentFlows/skin.ipml

participant "Payee (Merchant) Bank [Creditor Agent]" as MB
Participant "Payment Processor [Intermediary]" as MPSP
Participant "Payee (Merchant) Website [Creditor]" as Payee
participant "Payer's (Shopper's) Browser" as UA
Actor "Payer [Debtor]" as Payer
participant "Payment Mediator" as UAM
participant "Payment App" as PSPUI
participant "Payer (Shopper) Bank [Debtor Agent]" as CB


note over Payee, PSPUI: HTTPS

title PSP Mediated (SEPA) Credit Transfer

== Negotiation of Payment Terms & Selection of Payment Instrument ==

Payee->UA: Present Check-out page
Payer<-[#green]>UA: Select Checkout
Payer<-[#green]>Payee: Establish Payment Obligation (including delivery obligations)
Payee->UA: Payment and delivery details

UA->UAM: PaymentRequest (Items, Amounts, Shipping Options, <b><color:red>Credit Transfer IBAN</color></b> )
note right #aqua: PaymentRequest.Show()
opt
	Payer<-[#green]>UAM: Select Shipping Options	
	UAM->UA: Shipping Info
	note right #aqua: shippingoptionchange or shippingaddresschange events

	UA->UAM: Revised PaymentRequest
end
Payer<-[#green]>UAM: Select <b><color:red>Credit Transfer</color></b> Payment Instrument

UAM<-[#green]>PSPUI: Invoke Payment App (Instrument)

note right: IBAN details displayed on screen with details about how to make payment, potential printed details

Payer<-[#green]>PSPUI: Authorise

PSPUI->UAM: Payment App Response

UAM->UA: Payment App Response

Note Right #aqua: Show() Promise Resolves 

UA->MPSP: Payment App Response

MPSP->UA: Received

== Notification ==

UA->UAM: Payment Completetion Status

note over UAM #aqua: response.complete(status)

UAM->UA: UI Removed

note over UAM #aqua: complete promise resolves

UA->UA: Navigate to Result Page

MPSP-[#black]>Payee: Payment Notification (Pending)




Note over Payer: Payer now must invoke Credit Transfer manually via some means, e.g. Phone, WebBanking etc. (automated invocation will become possible as part of PSD 2 implementation)

...

== ISO20022/SEPA Credit Transfer ==

	Payer -> CB: CustomerCreditTransferInitiation
	CB -> Payer: CustomerPaymentStatusReport
	CB -> MB : FIToFICustormerCreditTransfer
	MB -> MPSP : BankToCustomerDebitCreditNotification

== Notification ==	

MPSP-[#black]>Payee: Payment Notification (Cleared)
Payee-[#black]>Payer: Payment Notification (email)

...

== Fulfilment ==

Payee->Payer: Provide products or services

@enduml
