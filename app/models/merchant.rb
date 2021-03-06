class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items
  has_many :customers, through: :invoices

  def self.search(params)
    case
      when params["id"]
        Merchant.find_by(id: params["id"].to_i)
      when params["name"]
        Merchant.find_by(name: params["name"])
      when params["created_at"]
        Merchant.find_by(created_at: params["created_at"].to_datetime)
      when params["updated_at"]
        Merchant.find_by(updated_at: params["updated_at"].to_datetime)
      when params
        Merchant.find_by(id: rand(1..Merchant.count))
    end
  end

  def self.search_all(params)
    case
      when params["id"]
        Merchant.where(id: params["id"].to_i)
      when params["name"]
        Merchant.where(name: params["name"])
      when params["created_at"]
        Merchant.where(created_at: params["created_at"].to_datetime)
      when params["updated_at"]
        Merchant.where(updated_at: params["updated_at"].to_datetime)
    end
  end

  def self.revenue(params)
    case
    when params[:date]
      Merchant.merchant_revenue_by_invoice_date_response(params[:merchant_id], params[:date])
    when params[:merchant_id]
      Merchant.single_merchant_revenue_response(params[:merchant_id])
    end
  end

  def self.single_merchant_revenue(merchant_id)
    select("merchants.id, sum(invoice_items.quantity * invoice_items.unit_price) as revenue")
    .joins(invoices: [:transactions, :invoice_items])
    .group("merchants.id")
    .having("merchants.id = ?", merchant_id)
    .merge(Transaction.unscoped.successful)
    .first
    .revenue
  end

  def self.single_merchant_revenue_response(merchant_id)
    money = (single_merchant_revenue(merchant_id) / 100.0).to_s
    { revenue: money }
  end

  def self.merchant_revenue_by_invoice_date(merchant_id, invoice_date)
    select("merchants.id, sum(invoice_items.quantity * invoice_items.unit_price) as revenue")
    .joins(invoices: [:transactions, :invoice_items])
    .group("merchants.id")
    .having("merchants.id = ?", merchant_id)
    .where("invoices.created_at = ?", invoice_date)
    .merge(Transaction.unscoped.successful)
    .first
    .revenue
  end

  def self.merchant_revenue_by_invoice_date(merchant_id, invoice_date)
    select("merchants.id, sum(invoice_items.quantity * invoice_items.unit_price) as revenue")
    .joins(invoices: [:transactions, :invoice_items])
    .group("merchants.id")
    .having("merchants.id = ?", merchant_id)
    .where("invoices.created_at = ?", invoice_date)
    .merge(Transaction.unscoped.successful)
    .first
    .revenue
  end

  def self.merchant_revenue_by_invoice_date_response(merchant_id, invoice_date)
    money = (merchant_revenue_by_invoice_date(merchant_id, invoice_date) / 100.0).to_s
    { revenue: money }
  end

  def self.favorite_customer(merchant_id)
    find(merchant_id)
    .customers
    .select('customers.*, count(transactions)')
    .joins(invoices: :transactions)
    .group('customers.id')
    .order('count DESC')
    .merge(Transaction.unscoped.successful)
    .first
  end

  def self.most_revenue(quantity)
    unscoped
    .select("merchants.*, sum(invoice_items.quantity * invoice_items.unit_price) as revenue")
    .joins(invoices: [:transactions, :invoice_items])
    .group('merchants.id')
    .order('revenue DESC')
    .merge(Transaction.unscoped.successful)
    .limit(quantity)
  end

  def self.all_merchants_revenue_for_date(date)
    joins(invoices: [:transactions, :invoice_items])
    .where("invoices.created_at = ?", date.to_datetime)
    .merge(Transaction.unscoped.successful)
    .sum("invoice_items.quantity * invoice_items.unit_price")
  end

  def self.format_all_merchants_revenue_for_date(date)
    money = (all_merchants_revenue_for_date(date)/100.0).to_s
    { total_revenue: money }
  end

  def self.merchants_selling_most_items(quantity)
    unscoped
    .select("merchants.id, merchants.name, sum(invoice_items.quantity)")
    .joins(invoices: [:invoice_items, :transactions])
    .merge(Transaction.unscoped.successful)
    .group("merchants.id")
    .order("sum DESC")
    .limit(quantity)
  end

  def self.sql(merchant_id)
    "SELECT DISTINCT customers.*, transactions.result, merchant.* FROM customers INNER JOIN invoices ON invoices.customer_id = customers.id INNER JOIN transactions ON transactions.invoice_id = invoices.id INNER JOIN merchants ON invoices.merchant_id = merchants.id WHERE transactions.result = 'failed' AND merchants.id = #{merchant_id} EXCEPT SELECT DISTINCT customers.*, transactions.result, merchant.* FROM customers INNER JOIN invoices ON invoices.customer_id = customers.id INNER JOIN transactions ON transactions.invoice_id = invoices.id INNER JOIN merchants ON invoices.merchant_id = merchants.id WHERE transactions.result = 'success' AND merchants.id = #{merchant_id}"
  end

  def self.pending_customers(merchant_id)
    find_by_sql(sql(merchant_id))
  end
end
