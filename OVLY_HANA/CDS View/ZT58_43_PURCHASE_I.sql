@AbapCatalog.sqlViewName: 'ZT5843_I_PO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Compras'
define view ZT58_43_PURCHASE_I

  as select from snwd_po as _Purchase
  association [1..1] to zt58_43_partners_i as _Partner
  on _Purchase.partner_guid = _Partner.NodeKey
{
  key node_key         as NodeKey,
      po_id            as PoId,
      created_by       as CreatedBy,
      created_at       as CreatedAt,
      changed_by       as ChangedBy,
      changed_at       as ChangedAt,
      note_guid        as NoteGuid,
      partner_guid     as PartnerGuid,
      currency_code    as CurrencyCode,
      gross_amount     as GrossAmount,
      net_amount       as NetAmount,
      tax_amount       as TaxAmount,
      lifecycle_status as LifecycleStatus,
      approval_status  as ApprovalStatus,
      confirm_status   as ConfirmStatus,
      ordering_status  as OrderingStatus,
      invoicing_status as InvoicingStatus,
      overall_status   as OverallStatus,

      //Association Publish
      _Partner
}
