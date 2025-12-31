from sqlalchemy import (Column, String, Integer, Text, DateTime, Boolean, ForeignKey, Numeric, ARRAY)
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from uuid import uuid4
import uuid
from typing import List, Optional
from datetime import datetime

Base = declarative_base()

# =========================
# USER
# =========================
class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, nullable=False)
    name = Column(String, nullable=True)
    phone = Column(String, nullable=True)
    password_hash = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    listings = relationship("Listing", back_populates="seller")
    offers_made = relationship(
        "Offer", foreign_keys="Offer.buyer_id", back_populates="buyer"
    )
    # offers_received = relationship(
    #     "Offer", foreign_keys="Offer.seller_id", back_populates="seller_user"
    # )
    sent_messages = relationship(
        "Message", foreign_keys="Message.sender_id", back_populates="sender"
    )
    received_messages = relationship(
        "Message", foreign_keys="Message.receiver_id", back_populates="receiver"
    )

# =========================
# LISTING
# =========================
class Listing(Base):
    __tablename__ = "listings"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    price_cents = Column(Integer, nullable=False)

    category_id = Column(UUID(as_uuid=True), ForeignKey("categories.id"),)

    seller_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False
    )
    images = relationship("ListingImage", back_populates="listing", cascade="all, delete-orphan")
    condition = Column(String, nullable=False)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
    )

    seller = relationship("User", back_populates="listings")
    category = relationship("Category")
    offers = relationship("Offer", back_populates="listing", cascade="all, delete-orphan")

# =========================
# LISTING IMAGE
# =========================
class ListingImage(Base):
    __tablename__ = "listing_images"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)
    listing_id = Column(UUID(as_uuid=True), ForeignKey("listings.id"), nullable=False)
    url = Column(String, nullable=False)
    position = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    listing = relationship("Listing", back_populates="images")


# =========================
# OFFER
# =========================
class Offer(Base):
    __tablename__ = "offers"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    listing_id = Column(
        UUID(as_uuid=True),
        ForeignKey("listings.id"),
        nullable=False
    )

    buyer_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        nullable=False
    )

    price_cents = Column(Integer, nullable=False)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False
    )

    listing = relationship("Listing", back_populates="offers")
    buyer = relationship("User", back_populates="offers_made")

# =========================
# MESSAGE
# =========================
class Message(Base):
    __tablename__ = "messages"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    listing_id = Column(UUID(as_uuid=True), ForeignKey("listings.id"), nullable=False)
    sender_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    receiver_id = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    content = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    sender = relationship(
        "User", foreign_keys=[sender_id], back_populates="sent_messages"
    )
    receiver = relationship(
        "User", foreign_keys=[receiver_id], back_populates="received_messages"
    )

class Category(Base):
    __tablename__ = "categories"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False)
    slug = Column(String, nullable=False, unique=True)

    parent_id = Column(UUID(as_uuid=True), ForeignKey("categories.id"), nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    # Self-referencing relationship (optional but good)
    parent = relationship(
        "Category",
        remote_side=[id],
        backref="children",
        lazy="selectin",
    )