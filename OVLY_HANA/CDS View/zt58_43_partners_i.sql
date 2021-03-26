@AbapCatalog.sqlViewName: 'ZT5843_I_BPA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Parceiros'
define view zt58_43_partners_i 

as select from snwd_bpa as Partner

association[0..*] to zt58_43_products_i as _Product
on Partner.node_key = _Product.SupplierGuid

association [0..*] to ZT58_43_PURCHASE_I as _Purchase
on Partner.node_key = _Purchase.PartnerGuid
{
    key node_key as NodeKey,
    bp_role as BpRole,
    email_address as EmailAddress,
    phone_number as PhoneNumber,
    fax_number as FaxNumber,
    web_address as WebAddress,
    address_guid as AddressGuid,
    bp_id as BpId,
    company_name as CompanyName,
    legal_form as LegalForm,
    created_by as CreatedBy,
    created_at as CreatedAt,
    changed_by as ChangedBy,
    changed_at as ChangedAt,
    currency_code as CurrencyCode,
    dummy_field_bpa as DummyFieldBpa,
    approval_status as ApprovalStatus,
    
    //Association publish
    _Product,
    _Purchase
}
where Partner.bp_role = '02'
