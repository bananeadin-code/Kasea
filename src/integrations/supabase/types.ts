export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      collections: {
        Row: {
          created_at: string
          description: string
          handle: string
          id: string
          position: number
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string
          handle: string
          id?: string
          position?: number
          title?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string
          handle?: string
          id?: string
          position?: number
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      products: {
        Row: {
          created_at: string
          currency: string
          description: string
          handle: string
          id: string
          is_custom: boolean
          position: number
          status: string
          tags: string[]
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          currency?: string
          description?: string
          handle: string
          id?: string
          is_custom?: boolean
          position?: number
          status?: string
          tags?: string[]
          title: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          currency?: string
          description?: string
          handle?: string
          id?: string
          is_custom?: boolean
          position?: number
          status?: string
          tags?: string[]
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      product_variants: {
        Row: {
          created_at: string
          currency: string
          id: string
          position: number
          price_cents: number
          product_id: string
          selected_options: Json
          sku: string | null
          stock: number
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          currency?: string
          id?: string
          position?: number
          price_cents: number
          product_id: string
          selected_options?: Json
          sku?: string | null
          stock?: number
          title?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          currency?: string
          id?: string
          position?: number
          price_cents?: number
          product_id?: string
          selected_options?: Json
          sku?: string | null
          stock?: number
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_variants_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      product_images: {
        Row: {
          alt: string
          created_at: string
          id: string
          position: number
          product_id: string
          url: string
        }
        Insert: {
          alt?: string
          created_at?: string
          id?: string
          position?: number
          product_id: string
          url: string
        }
        Update: {
          alt?: string
          created_at?: string
          id?: string
          position?: number
          product_id?: string
          url?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_images_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      product_collections: {
        Row: {
          collection_id: string
          position: number
          product_id: string
        }
        Insert: {
          collection_id: string
          position?: number
          product_id: string
        }
        Update: {
          collection_id?: string
          position?: number
          product_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_collections_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "product_collections_collection_id_fkey"
            columns: ["collection_id"]
            isOneToOne: false
            referencedRelation: "collections"
            referencedColumns: ["id"]
          },
        ]
      }
      shop_settings: {
        Row: {
          id: string
          notify_email: string | null
          shipping_flat_cents: number
          shipping_free_threshold_cents: number
          updated_at: string
        }
        Insert: {
          id?: string
          notify_email?: string | null
          shipping_flat_cents?: number
          shipping_free_threshold_cents?: number
          updated_at?: string
        }
        Update: {
          id?: string
          notify_email?: string | null
          shipping_flat_cents?: number
          shipping_free_threshold_cents?: number
          updated_at?: string
        }
        Relationships: []
      }
      custom_designs: {
        Row: {
          color: string | null
          created_at: string
          font: string | null
          font_size: number | null
          id: string
          image_url: string | null
          model: string | null
          params: Json
          pos_x: number | null
          pos_y: number | null
          preview_url: string | null
          rotation: number | null
          text_content: string | null
        }
        Insert: {
          color?: string | null
          created_at?: string
          font?: string | null
          font_size?: number | null
          id?: string
          image_url?: string | null
          model?: string | null
          params?: Json
          pos_x?: number | null
          pos_y?: number | null
          preview_url?: string | null
          rotation?: number | null
          text_content?: string | null
        }
        Update: {
          color?: string | null
          created_at?: string
          font?: string | null
          font_size?: number | null
          id?: string
          image_url?: string | null
          model?: string | null
          params?: Json
          pos_x?: number | null
          pos_y?: number | null
          preview_url?: string | null
          rotation?: number | null
          text_content?: string | null
        }
        Relationships: []
      }
      orders: {
        Row: {
          created_at: string
          currency: string
          customer_name: string | null
          delivery_method: string
          email: string | null
          id: string
          needs_review: boolean
          phone: string | null
          shipping_address: Json | null
          shipping_cents: number
          status: string
          stripe_payment_intent: string | null
          stripe_session_id: string
          subtotal_cents: number
          total_cents: number
          updated_at: string
        }
        Insert: {
          created_at?: string
          currency?: string
          customer_name?: string | null
          delivery_method?: string
          email?: string | null
          id?: string
          needs_review?: boolean
          phone?: string | null
          shipping_address?: Json | null
          shipping_cents?: number
          status?: string
          stripe_payment_intent?: string | null
          stripe_session_id: string
          subtotal_cents?: number
          total_cents?: number
          updated_at?: string
        }
        Update: {
          created_at?: string
          currency?: string
          customer_name?: string | null
          delivery_method?: string
          email?: string | null
          id?: string
          needs_review?: boolean
          phone?: string | null
          shipping_address?: Json | null
          shipping_cents?: number
          status?: string
          stripe_payment_intent?: string | null
          stripe_session_id?: string
          subtotal_cents?: number
          total_cents?: number
          updated_at?: string
        }
        Relationships: []
      }
      order_items: {
        Row: {
          attributes: Json
          created_at: string
          custom_design_id: string | null
          id: string
          order_id: string
          product_handle: string | null
          quantity: number
          title: string
          unit_price_cents: number
          variant_id: string | null
        }
        Insert: {
          attributes?: Json
          created_at?: string
          custom_design_id?: string | null
          id?: string
          order_id: string
          product_handle?: string | null
          quantity?: number
          title: string
          unit_price_cents?: number
          variant_id?: string | null
        }
        Update: {
          attributes?: Json
          created_at?: string
          custom_design_id?: string | null
          id?: string
          order_id?: string
          product_handle?: string | null
          quantity?: number
          title?: string
          unit_price_cents?: number
          variant_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "order_items_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_items_variant_id_fkey"
            columns: ["variant_id"]
            isOneToOne: false
            referencedRelation: "product_variants"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_items_custom_design_id_fkey"
            columns: ["custom_design_id"]
            isOneToOne: false
            referencedRelation: "custom_designs"
            referencedColumns: ["id"]
          },
        ]
      }
      stripe_events: {
        Row: {
          created_at: string
          id: string
          type: string | null
        }
        Insert: {
          created_at?: string
          id: string
          type?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          type?: string | null
        }
        Relationships: []
      }
      carousel_images: {
        Row: {
          alt: string
          created_at: string
          description: string
          id: string
          image_key: string
          image_url: string
          position: number
          title: string
          updated_at: string
        }
        Insert: {
          alt?: string
          created_at?: string
          description?: string
          id?: string
          image_key: string
          image_url?: string
          position: number
          title?: string
          updated_at?: string
        }
        Update: {
          alt?: string
          created_at?: string
          description?: string
          id?: string
          image_key?: string
          image_url?: string
          position?: number
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      category_images: {
        Row: {
          alt: string
          image_url: string
          slug: string
          title: string
          updated_at: string
        }
        Insert: {
          alt?: string
          image_url: string
          slug: string
          title?: string
          updated_at?: string
        }
        Update: {
          alt?: string
          image_url?: string
          slug?: string
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      product_image_overrides: {
        Row: {
          alt: string
          created_at: string
          id: string
          image_url: string
          is_uploaded: boolean
          position: number
          product_handle: string
          title: string
          updated_at: string
        }
        Insert: {
          alt?: string
          created_at?: string
          id?: string
          image_url: string
          is_uploaded?: boolean
          position: number
          product_handle: string
          title?: string
          updated_at?: string
        }
        Update: {
          alt?: string
          created_at?: string
          id?: string
          image_url?: string
          is_uploaded?: boolean
          position?: number
          product_handle?: string
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      product_order: {
        Row: {
          created_at: string
          id: string
          position: number
          product_handle: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          position: number
          product_handle: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          position?: number
          product_handle?: string
          updated_at?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      has_role: {
        Args: { _user_id: string; _role: Database["public"]["Enums"]["app_role"] }
        Returns: boolean
      }
      product_sales_ranking: {
        Args: Record<PropertyKey, never>
        Returns: { product_id: string; units: number }[]
      }
      process_paid_order: {
        Args: {
          _session_id: string
          _payment_intent: string | null
          _email: string | null
          _name: string | null
          _phone: string | null
          _address: Json
          _delivery_method: string
          _currency: string
          _subtotal_cents: number
          _shipping_cents: number
          _total_cents: number
          _items: Json
        }
        Returns: Json
      }
    }
    Enums: {
      app_role: "admin"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      app_role: ["admin"],
    },
  },
} as const
