import { Link } from "@tanstack/react-router";
import logoAsset from "@/assets/kasea-logo.png.asset.json";

interface BrandLogoProps {
  className?: string;
  imageClassName?: string;
  priority?: boolean;
}

export function BrandLogo({ className, imageClassName, priority = false }: BrandLogoProps) {
  return (
    <Link to="/" className={className} aria-label="Kasea Store, volver al inicio">
      <img
        src={logoAsset.url}
        alt="Logo de Kasea Store"
        className={imageClassName}
        loading={priority ? undefined : "lazy"}
        fetchPriority={priority ? "high" : undefined}
      />
    </Link>
  );
}
